#!/usr/bin/env python3
"""Prépare la police d'icônes de Mekano Afrika.

Les `Icons` du SDK Flutter datent de 2018. L'application embarque à la place
les Material Symbols Rounded, génération courante du catalogue Material, dans
une version réduite aux seuls glyphes réellement utilisés.

Le script enchaîne quatre étapes :

1. il recense les icônes appelées dans `lib/`, sous la forme `Symboles.xxx` ou
   `Icons.xxx`, afin qu'une icône ajoutée à l'application suive automatiquement ;
2. il normalise ces noms vers ceux du catalogue Material : les variantes
   `_outlined`, `_rounded` ou `_border` de Flutter n'existent pas côté Symbols,
   où contour et plein sont le même glyphe posé avec un axe `FILL` différent ;
3. il sous-ensemble la police variable aux glyphes retenus, puis fige les axes
   `opsz` et `GRAD` dont l'application n'a pas l'usage. `FILL` et `wght`
   restent libres : ils se pilotent à l'affichage, sans glyphe supplémentaire ;
4. il génère `lib/theme/symboles.dart`.

Usage : python3 tool/preparer_symboles.py
"""

import re
import subprocess
import sys
import urllib.request
from pathlib import Path

PROJET = Path(__file__).resolve().parent.parent
POLICE = PROJET / "assets" / "fonts" / "MaterialSymbolsRounded.ttf"
SORTIE_DART = PROJET / "lib" / "theme" / "symboles.dart"
CACHE = PROJET / "build" / "symboles"

DEPOT = (
    "https://raw.githubusercontent.com/google/material-design-icons/master"
    "/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D"
)

# Logos de marque, absents des Material Symbols : ils restent pris dans les
# `Icons` du SDK, à l'écran de connexion.
EXCLUES = {"facebook", "g_mobiledata_rounded"}

SUFFIXES = ("_outlined", "_rounded", "_outline", "_sharp", "_border", "_none")

# Correspondances qui ne se déduisent pas du simple retrait d'un suffixe.
SPECIALES = {
    "star_outline_rounded": "star",
    "star_half_rounded": "star_half",
    "favorite_border": "favorite",
    "person_outline": "person",
    "help_outline": "help",
    "info_outline": "info",
    "error_outline": "error",
    "notifications_none": "notifications",
}


def telecharger(suffixe: str, destination: Path) -> None:
    if destination.exists():
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    print(f"téléchargement de {destination.name}…")
    urllib.request.urlretrieve(f"{DEPOT}{suffixe}", destination)


def recenser() -> set[str]:
    """Noms d'icônes appelés dans le code, en camelCase comme en snake_case."""
    motif = re.compile(r"\b(?:Icons|Symboles)\.([a-zA-Z0-9_]+)")
    noms = set()
    for source in (PROJET / "lib").rglob("*.dart"):
        if source == SORTIE_DART:
            continue
        noms.update(motif.findall(source.read_text(encoding="utf-8")))
    return noms


def en_snake(nom: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "_", nom).lower()


def normaliser(nom: str) -> str:
    nom = en_snake(nom)
    if nom in SPECIALES:
        return SPECIALES[nom]
    precedent = None
    while precedent != nom:
        precedent = nom
        for suffixe in SUFFIXES:
            if nom.endswith(suffixe):
                nom = nom[: -len(suffixe)]
    return nom


def en_camel(nom: str) -> str:
    morceaux = nom.split("_")
    return morceaux[0] + "".join(m.capitalize() for m in morceaux[1:])


ENTETE = '''import 'package:flutter/widgets.dart';

/// Glyphes Material Symbols Rounded embarqués par l'application.
///
/// Les `Icons` du SDK datent de 2018 : leur dessin trahit l'âge d'une
/// interface. La police retenue ici est la génération courante du catalogue
/// Material, dans sa variante arrondie, réduite aux seuls glyphes utilisés,
/// une soixantaine de kilo-octets, ce qui reste tenable pour le téléphone
/// d'entrée de gamme visé par le cahier des charges.
///
/// Elle est **variable** : le remplissage et l'épaisseur du trait se pilotent
/// à l'affichage, sans glyphe supplémentaire. Une icône pleine et son contour
/// sont donc le même symbole, posé avec un `fill` différent :
///
/// ```dart
/// Icon(Symboles.favorite)          // contour
/// Icon(Symboles.favorite, fill: 1) // plein
/// ```
///
/// Les noms restent ceux du catalogue Material : ils désignent un glyphe et
/// non une notion métier, et doivent pouvoir être retrouvés tels quels sur
/// fonts.google.com/icons.
///
/// Fichier engendré par `tool/preparer_symboles.py` : toute retouche manuelle
/// sera perdue à la prochaine exécution.
class Symboles {
  const Symboles._();

  /// Famille déclarée au `pubspec.yaml`.
  static const String famille = 'Symboles';
'''


def main() -> int:
    source_ttf = CACHE / "MaterialSymbolsRounded.ttf"
    source_codepoints = CACHE / "MaterialSymbolsRounded.codepoints"
    telecharger(".ttf", source_ttf)
    telecharger(".codepoints", source_codepoints)

    codepoints = {}
    for ligne in source_codepoints.read_text(encoding="utf-8").splitlines():
        nom, code = ligne.split()
        codepoints[nom] = int(code, 16)

    retenues, manquantes = {}, []
    for brute in sorted(recenser()):
        if brute in EXCLUES or brute == "famille":
            continue
        glyphe = normaliser(brute)
        if glyphe in codepoints:
            retenues[glyphe] = codepoints[glyphe]
        else:
            manquantes.append((brute, glyphe))

    if manquantes:
        print("glyphes introuvables au catalogue :")
        for brute, glyphe in manquantes:
            print(f"  {brute} → {glyphe}")

    intermediaire = CACHE / "sous-ensemble.ttf"
    unicodes = ",".join(f"U+{c:04X}" for c in sorted(retenues.values()))
    subprocess.run(
        [
            sys.executable, "-m", "fontTools.subset", str(source_ttf),
            f"--unicodes={unicodes}",
            "--layout-features=*",
            "--no-hinting",
            "--desubroutinize",
            f"--output-file={intermediaire}",
        ],
        check=True,
    )

    # `opsz` et `GRAD` sont figés : l'application pose ses icônes à une seule
    # taille optique et sans correction de graisse. Les fixer divise le poids
    # du fichier par près de quatre.
    POLICE.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            sys.executable, "-m", "fontTools.varLib.instancer", str(intermediaire),
            "opsz=24", "GRAD=0", "-o", str(POLICE),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )

    lignes = [ENTETE, ""]
    for glyphe in sorted(retenues):
        lignes.append(
            f"  static const IconData {en_camel(glyphe)} = "
            f"IconData(0x{retenues[glyphe]:x}, fontFamily: famille);"
        )
    lignes += ["}", ""]
    SORTIE_DART.write_text("\n".join(lignes), encoding="utf-8")

    poids = POLICE.stat().st_size / 1024
    print(f"{len(retenues)} glyphes · {poids:.0f} ko · {POLICE.relative_to(PROJET)}")
    return 1 if manquantes else 0


if __name__ == "__main__":
    raise SystemExit(main())
