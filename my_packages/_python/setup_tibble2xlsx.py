from setuptools import setup, find_packages

VERSION = '0.0.1' 
DESCRIPTION = 'From R tibble to xls files'
LONG_DESCRIPTION = 'R tibbles can be transmformed into polished xls files'

# Setting up
setup(
        name="tibble2xlsx", 
        version=VERSION,
        author="Pierre Balaye",
        author_email="<pierre@balaye.fr>",
        description=DESCRIPTION,
        long_description=LONG_DESCRIPTION,
        packages=find_packages(),
        install_requires=[pandas, XlsxWriter], # add any additional packages that 
        # needs to be installed along with your package. Eg: 'caer'

        keywords=['python', 'xlsx', 'R', 'tibble', 'dataframe'],
        classifiers= [
            "Development Status :: 3 - Alpha",
            "Intended Audience :: Education",
            "Programming Language :: Python :: 3",
            "Operating System :: Linuyx :: yourOS",
        ]
)
