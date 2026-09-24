#!/usr/bin/env python3
"""Prépare les déclinaisons du logo de Mekano Afrika.

Le logo livré — `assets/images/logo_mekano/mekano_afrika.png` — est une
constellation : un disque central portant le M sur la carte d'Afrique, relié
par six antennes à des nœuds satellites. Cette figure est juste, mais elle ne
peut pas servir telle quelle partout, pour trois raisons mesurées sur le
fichier source :

1. **elle est décentrée.** Le dessin occupe la boîte (112, 77)-(427, 384) d'un
   carré de 512 : posée dans un conteneur centré, la marque paraît désaxée ;
2. **ses antennes sont noires.** Le splash et l'onboarding sont sur fond noir,
   où les liaisons et les satellites disparaîtraient purement et simplement ;
3. **ses détails sont fins.** À 48 px — la taille d'une icône d'application et
   d'un logo d'en-tête — les antennes deviennent une poussière illisible.

Le script produit donc trois dérivés, chacun pour un emploi précis, plus les
icônes de lancement Android. La source n'est jamais modifiée : elle reste la
référence à partir de laquelle tout se régénère.

Usage : python3 tool/preparer_logo.py
"""

from pathlib import Path

from PIL import Image, ImageDraw

PROJET = Path(__file__).resolve().parent.parent
DOSSIER = PROJET / "assets" / "images" / "logo_mekano"
SOURCE = DOSSIER / "mekano_afrika.png"
RES_ANDROID = PROJET / "android" / "app" / "src" / "main" / "res"

# Géométrie du disque central, relevée sur la source : c'est lui qui devient le
# monogramme. Le rayon retenu est celui de l'anneau extérieur.
CENTRE = (256.5, 225.0)
RAYON = 88.0

# Couleurs de la charte, celles de `lib/theme/couleurs.dart`.
ORANGE = (242, 107, 15)
NOIR = (18, 17, 16)
BLANC = (255, 255, 255)

# Couleurs telles qu'elles sortent du générateur d'images. L'orange livré
# (#FC8202) est plus clair et plus jaune que celui de la charte : laissé tel
# quel, le logo jurerait avec les boutons et les prix de l'application.
ORANGE_SOURCE = (252, 130, 2)
NOIR_SOURCE = (22, 22, 19)

# Tolérance de reconnaissance des couleurs. Le PNG est indexé mais ses bords
# sont lissés : les pixels de transition doivent être rattachés à leur teinte.
TOLERANCE = 60

# Densités Android et côté de l'icône, en pixels.
DENSITES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}


def proche(pixel, reference, tolerance=TOLERANCE):
    """Vrai si `pixel` est la couleur `reference`, lissage des bords compris."""
    return all(abs(a - b) <= tolerance for a, b in zip(pixel[:3], reference))


def reteinter(image, remplacements):
    """Remplace des couleurs en conservant l'alpha et la douceur des bords.

    Le lissage est préservé en reportant le canal alpha d'origine : seule la
    teinte change, jamais la forme.
    """
    resultat = image.copy()
    pixels = resultat.load()
    largeur, hauteur = resultat.size

    for y in range(hauteur):
        for x in range(largeur):
            r, v, b, a = pixels[x, y]
            if a == 0:
                continue
            for depuis, vers in remplacements:
                if proche((r, v, b), depuis):
                    pixels[x, y] = (*vers, a)
                    break

    return resultat


def hors_du_disque(x, y, marge=4):
    """Vrai si le point appartient à la constellation, pas au disque central."""
    dx = x - CENTRE[0]
    dy = y - CENTRE[1]
    return dx * dx + dy * dy > (RAYON + marge) ** 2


def recentrer(image, marge=0.06):
    """Recadre sur le dessin, puis le repose au centre d'un carré.

    `marge` est la part du côté laissée libre de chaque côté. Sans elle, le
    logo toucherait les bords des conteneurs qui l'accueillent.
    """
    boite = image.getbbox()
    dessin = image.crop(boite)

    cote = max(dessin.size)
    plein = round(cote * (1 + 2 * marge))
    carre = Image.new("RGBA", (plein, plein), (0, 0, 0, 0))
    carre.paste(
        dessin,
        ((plein - dessin.width) // 2, (plein - dessin.height) // 2),
    )
    return carre.resize((512, 512), Image.LANCZOS)


def accorder_a_la_charte(image):
    """Aligne l'orange et le noir du logo sur ceux du thème."""
    return reteinter(
        image,
        [(ORANGE_SOURCE, ORANGE), (NOIR_SOURCE, NOIR)],
    )


def version_fond_sombre(image):
    """Éclaircit la constellation pour qu'elle survive sur fond noir.

    Hors du disque, les deux encres neutres sont **permutées** : le noir passe
    au blanc et le blanc au noir. Un simple noircissement ne suffirait pas —
    les satellites sont des pastilles noires portant un pictogramme blanc, et
    n'éclaircir que le noir rendrait ces pictogrammes invisibles sur la
    pastille devenue blanche.

    L'orange, lui, ne bouge jamais : c'est la constante de la marque. Le M
    reste noir également, car il repose sur le disque blanc, qui lui tient lieu
    de fond quel que soit l'écran. Le logo reste ainsi le même dessin, et non
    une seconde marque.
    """
    resultat = image.copy()
    pixels = resultat.load()
    largeur, hauteur = resultat.size

    for y in range(hauteur):
        for x in range(largeur):
            r, v, b, a = pixels[x, y]
            if a == 0 or not hors_du_disque(x, y):
                continue
            if proche((r, v, b), NOIR):
                pixels[x, y] = (*BLANC, a)
            elif proche((r, v, b), BLANC):
                pixels[x, y] = (*NOIR, a)

    return resultat


def monogramme(image):
    """Isole le disque central, seule partie lisible en petit.

    Le recadrage seul ne suffit pas : les six antennes traversent la fenêtre et
    laisseraient des moignons de traits dans les angles. Un masque circulaire
    les efface, pour que le disque sorte net sur n'importe quel fond.
    """
    disque = image.crop(
        (
            round(CENTRE[0] - RAYON),
            round(CENTRE[1] - RAYON),
            round(CENTRE[0] + RAYON),
            round(CENTRE[1] + RAYON),
        )
    ).resize((512, 512), Image.LANCZOS)

    # Masque tracé quatre fois trop grand puis réduit : c'est ce qui donne un
    # bord lissé, là où un cercle tracé à la taille finale serait crénelé.
    facteur = 4
    masque = Image.new("L", (512 * facteur, 512 * facteur), 0)
    ImageDraw.Draw(masque).ellipse(
        (0, 0, 512 * facteur - 1, 512 * facteur - 1), fill=255
    )
    masque = masque.resize((512, 512), Image.LANCZOS)

    decoupe = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    decoupe.paste(disque, (0, 0), masque)
    return decoupe


def icone_application(marque):
    """Pose le monogramme sur le noir de la charte, en pleine surface.

    Android affiche l'icône sur le fond d'écran de l'utilisateur : un logo
    transparent y serait illisible une fois sur deux. Le noir de la marque sert
    donc de conteneur, et le disque blanc ressort dessus.
    """
    fond = Image.new("RGBA", (512, 512), (*NOIR, 255))
    cote = round(512 * 0.72)
    reduit = marque.resize((cote, cote), Image.LANCZOS)
    fond.paste(reduit, ((512 - cote) // 2, (512 - cote) // 2), reduit)
    return fond


def main():
    source = Image.open(SOURCE).convert("RGBA")
    print(f"source : {SOURCE.relative_to(PROJET)} — {source.size[0]} px")

    accorde = accorder_a_la_charte(source)

    complet = recentrer(accorde)
    complet.save(DOSSIER / "mekano_afrika_complet.png")
    print("  → mekano_afrika_complet.png    constellation centrée, fond clair")

    sombre = recentrer(version_fond_sombre(accorde))
    sombre.save(DOSSIER / "mekano_afrika_sur_sombre.png")
    print("  → mekano_afrika_sur_sombre.png constellation éclaircie, fond noir")

    marque = monogramme(accorde)
    marque.save(DOSSIER / "mekano_afrika_monogramme.png")
    print("  → mekano_afrika_monogramme.png disque seul, lisible à 48 px")

    icone = icone_application(marque)
    for densite, cote in DENSITES.items():
        cible = RES_ANDROID / f"mipmap-{densite}" / "ic_launcher.png"
        cible.parent.mkdir(parents=True, exist_ok=True)
        icone.resize((cote, cote), Image.LANCZOS).convert("RGB").save(cible)
    print(f"  → android mipmap-*/ic_launcher.png ({len(DENSITES)} densités)")


if __name__ == "__main__":
    main()
