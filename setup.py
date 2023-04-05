from setuptools import setup, Extension
#from VerifyOwner.version import __version__

Vf_c=Extension(
    name='VerifyOwner.VerifyOwnerF',
    sources=['VerifyOwnerF.m'],
    extra_compile_args=['-ObjC++'],
    extra_link_args=['-framework','Cocoa','-framework','LocalAuthentication'],
    libraries=[]
)

setup(
    name='VerifyOwner',
    version='1.0.0',
    author='AliebcX',
    author_email='aliebcx@outlook.com',
    ext_modules=[Vf_c],
    description='A package to verify owner by Touch ID',
    license='MIT LICENSE',
    packages=['VerifyOwner'],
    platforms=['Darwin'],
    
)