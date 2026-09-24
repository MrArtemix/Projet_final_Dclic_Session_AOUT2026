#!/usr/bin/env python3
"""Ramène les images du projet à la taille où elles sont réellement affichées.

Les visuels livrés mesuraient jusqu'à 2560 pixels de côté, pour un affichage
qui n'en demande jamais plus de trois cents. Deux raisons de les réduire, et la
seconde est la plus sérieuse :

1. **Le poids du paquet.** Cinq cents mégaoctets d'images ne se distribuent pas
   sur un magasin d'applications, et encore moins sur le réseau instable que
   vise le cahier des charges.

2. **La mémoire vive.** Flutter décompresse chaque image affichée : une photo
   de 1920 sur 1920 occupe quatorze mégaoctets de mémoire, quel que soit le
   poids de son fichier. Quatre vignettes de la grille d'accueil suffisent
   alors à saturer un téléphone d'entrée de gamme.

Les originaux ne sont pas détruits : ils sont déplacés hors du dossier des
ressources, vers `documents/images_sources/`. Ils cessent ainsi de partir dans
l'application tout en restant disponibles pour une reprise.

Usage : python3 tool/optimiser_images.py [--verifier]
"""

import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image

Image.MAX_IMAGE_PIXELS = None

PROJET = Path(__file__).resolve().parent.parent
IMAGES = PROJET / "assets" / "images"
SOURCES = PROJET / "documents" / "images_sources"

# Côté maximal d'une photo. La galerie de la fiche produit occupe trois cents
# points ; à densité triple, mille deux cents pixels couvrent le besoin avec
# une marge confortable.
COTE_PHOTO = 1200

# Un logo n'est jamais affiché au-delà de soixante-dix-huit points.
COTE_LOGO = 512

QUALITE = 82

# Ce dossier porte un espace, qui complique les chemins de ressources.
RENOMMAGES = {"kits electroniq": "kits_electroniques"}


def transparence_utile(image: Image.Image) -> bool:
    """Vrai si le canal alpha porte autre chose que de l'opaque."""
    if image.mode not in ("RGBA", "LA", "P"):
        return False
    minimum, _ = image.convert("RGBA").getchannel("A").getextrema()
    return minimum < 250


def optimiser_photo(source: Path, destination: Path) -> None:
    """Réduit une photo et l'enregistre en JPEG progressif."""
    with Image.open(source) as image:
        image = image.convert("RGB")
        image.thumbnail((COTE_PHOTO, COTE_PHOTO), Image.LANCZOS)
        image.save(
            destination,
            "JPEG",
            quality=QUALITE,
            optimize=True,
            progressive=True,
        )


def optimiser_logo(source: Path, destination: Path) -> None:
    """Réduit un logo en préservant sa transparence.

    La palette est ramenée à soixante-quatre teintes : un logo n'en emploie
    qu'une poignée, et l'écart est invisible pour un fichier dix fois plus
    léger.
    """
    with Image.open(source) as image:
        image = image.convert("RGBA")
        image.thumbnail((COTE_LOGO, COTE_LOGO), Image.LANCZOS)
        reduite = image.quantize(colors=64, method=Image.FASTOCTREE)
        reduite.save(destination, "PNG", optimize=True)


def convertir_svg(source: Path, destination: Path) -> None:
    """Rend un SVG en PNG carré, le dessin centré sur fond transparent.

    Les logotypes livrés sont très allongés, cent soixante-dix sur vingt pour
    l'un d'eux. Or l'application découpe l'avatar d'une boutique en cercle : un
    bandeau y serait tronqué à ses deux extrémités. Le dessin est donc réduit
    puis centré dans un carré, avec une marge qui le préserve du recadrage.
    """
    intermediaire = destination.with_suffix(".rendu.png")
    subprocess.run(
        [
            "rsvg-convert",
            "--width", str(COTE_LOGO),
            "--keep-aspect-ratio",
            "--output", str(intermediaire),
            str(source),
        ],
        check=True,
    )

    with Image.open(intermediaire) as dessin:
        dessin = dessin.convert("RGBA")
        marge = int(COTE_LOGO * 0.12)
        utile = COTE_LOGO - 2 * marge
        dessin.thumbnail((utile, utile), Image.LANCZOS)

        carre = Image.new("RGBA", (COTE_LOGO, COTE_LOGO), (0, 0, 0, 0))
        carre.paste(
            dessin,
            ((COTE_LOGO - dessin.width) // 2, (COTE_LOGO - dessin.height) // 2),
            dessin,
        )
        carre.save(destination, "PNG", optimize=True)

    intermediaire.unlink()


def poids(chemin: Path) -> int:
    return sum(f.stat().st_size for f in chemin.rglob("*") if f.is_file())


def main() -> int:
    if not IMAGES.exists():
        print("assets/images introuvable")
        return 1

    if SOURCES.exists():
        print(f"{SOURCES.relative_to(PROJET)} existe déjà : rien n'est refait.")
        print("Supprimer ce dossier pour relancer l'optimisation depuis zéro.")
        return 1

    avant = poids(IMAGES)

    # Les originaux quittent le dossier des ressources avant toute retouche.
    SOURCES.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(IMAGES, SOURCES)
    print(f"originaux copiés vers {SOURCES.relative_to(PROJET)} "
          f"({poids(SOURCES) / 1048576:.0f} Mo)")

    # Dossiers dont le nom pose problème dans un chemin de ressource.
    for ancien, nouveau in RENOMMAGES.items():
        chemin = IMAGES / "photos_produit" / ancien
        if chemin.exists():
            chemin.rename(IMAGES / "photos_produit" / nouveau)
            print(f"renommé : {ancien} → {nouveau}")

    traitees = 0
    for fichier in sorted(IMAGES.rglob("*")):
        if not fichier.is_file() or fichier.name == "grain.png":
            continue

        suffixe = fichier.suffix.lower()
        est_logo = "logo" in fichier.parent.name

        try:
            if suffixe == ".svg":
                convertir_svg(fichier, fichier.with_suffix(".png"))
                fichier.unlink()
            elif est_logo:
                optimiser_logo(fichier, fichier.with_suffix(".png"))
                if suffixe != ".png":
                    fichier.unlink()
            elif suffixe in (".png", ".jpg", ".jpeg"):
                optimiser_photo(fichier, fichier.with_suffix(".jpg"))
                if suffixe == ".png":
                    fichier.unlink()
            else:
                continue
            traitees += 1
        except Exception as erreur:
            print(f"  échec sur {fichier.name} : {erreur}")

    # Les fichiers système de macOS n'ont rien à faire dans un paquet.
    for parasite in IMAGES.rglob(".DS_Store"):
        parasite.unlink()

    apres = poids(IMAGES)
    print(f"\n{traitees} images traitées")
    print(f"assets/images : {avant / 1048576:.0f} Mo → {apres / 1048576:.1f} Mo "
          f"(facteur {avant / max(apres, 1):.0f})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
