from setuptools import setup

APP = ['freelan-bar.py']
DATA_FILES = ['Resources/freelan-bar.png']
OPTIONS = {
    'argv_emulation': True,
    'iconfile':'Resources/freelan-bar.icns',
    'plist': {
        'LSUIElement': True,
    },
    'packages': ['rumps'],
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)