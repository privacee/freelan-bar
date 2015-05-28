from setuptools import setup, find_packages

APP = ['freelan-bar.py']
DATA_FILES = [
    'Resources/freelan-bar_st_bw.png',
    'Resources/freelan-bar_st.png',
    'Resources/freelan-bar.png']
OPTIONS = {
    'argv_emulation': True,
    'iconfile':'Resources/freelan-bar.icns',
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
    packages=find_packages(),
    scripts=['freelan-bar.py'],
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
    install_requires=['freelan-configurator'],
)