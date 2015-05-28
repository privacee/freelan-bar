from setuptools import setup

APP = ['freelan-bar.py']
DATA_FILES = [
    'xcode-swift/Resources/freelan-bar_st_bw.png',
    'xcode-swift/Resources/freelan-bar_st.png',
    'xcode-swift/Resources/freelan-bar.png']
OPTIONS = {
    'argv_emulation': True,
    'iconfile':'xcode-swift/Resources/freelan-bar.icns',
    'plist': {
        'LSUIElement': True,
    },
    'packages': ['rumps', 'freelan-configurator'],
}

setup(
    name='freelan-bar',
    version='0.1',
    license='MIT',
    author='Christoph Russ',
    author_email='chruss@gmx.de',
    packages='freelan-bar',
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
    install_requires=['freelan-configurator'],
)