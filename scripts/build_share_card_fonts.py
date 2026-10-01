"""Build the share-only typefaces. Requires fonttools in a Python virtualenv.

Usage: python scripts/build_share_card_fonts.py /path/to/downloaded/sources
Sources: Google Fonts (revision recorded in assets/fonts/share_card/SOURCES.txt).
Asian fonts include the share-card copy, not arbitrary profile names (which fall
back to the device font). Re-run when adding translated share-card characters.
"""
from pathlib import Path
import json, sys
from fontTools.ttLib import TTFont
from fontTools import subset
from fontTools.varLib.instancer import instantiateVariableFont

root = Path(__file__).resolve().parents[1]
source = Path(sys.argv[1])
output = root / 'assets/fonts/share_card'
locales = {'SC': 'zh', 'TC': 'zh_Hant', 'JP': 'ja', 'KR': 'ko', 'Thai': 'th'}
for family in ['Latin', *locales]:
    font = TTFont(source / f'{family}.ttf')
    if family in locales:
        arb = json.loads((root / f'lib/l10n/app_{locales[family]}.arb').read_text())
        characters = ''.join(v for k, v in arb.items() if isinstance(v, str) and (
            k.startswith('wordActivity') or k.startswith('language')))
        # Subset before instancing to avoid processing tens of thousands of glyphs.
        options = subset.Options()
        options.name_IDs = ['*']
        options.name_legacy = True
        options.name_languages = ['*']
        sub = subset.Subsetter(options=options)
        sub.populate(text=characters)
        sub.subset(font)
    for weight in ([600, 700, 900] if family == 'Latin' else [600, 900]):
        axes = {a.axisTag: a.defaultValue for a in font['fvar'].axes}
        axes['wght'] = weight
        if 'opsz' in axes:
            axes['opsz'] = 32
        instance = instantiateVariableFont(font, axes, inplace=False)
        # Renamed derivatives comply with the original reserved font names.
        name = f'BanteraShare{family}'
        for record in instance['name'].names:
            if record.nameID in (1, 2, 3, 4, 6, 16, 17):
                text = name if record.nameID in (1, 16) else (
                    str(weight) if record.nameID in (2, 17) else f'{name}-{weight}')
                record.string = text.encode(record.getEncoding())
        path = output / f'{name}-{weight}.ttf'
        instance.save(path)
        print(path.name, path.stat().st_size)
revision = (source / 'revision').read_text().strip()
(output / 'SOURCES.txt').write_text(
    'Source: https://github.com/google/fonts/tree/' + revision + '/ofl\n'
    'Latin: inter; SC: notosanssc; TC: notosanstc; JP: notosansjp; '
    'KR: notosanskr; Thai: notosansthai.\n'
    'Derived with scripts/build_share_card_fonts.py. Asian subsets cover localized '
    'share strings; fonts are statically instanced and renamed BanteraShare*.\n'
    'Original copyrights and SIL Open Font Licenses are in the accompanying *-OFL.txt files.\n')
