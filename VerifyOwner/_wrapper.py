import platform

if platform.system() != "Darwin":
  raise SystemError("VerifyOwner only supports MacOS.")

__all__ = ['VerifyOwner']

from VerifyOwner.VerifyOwnerF import VerifyOwnerF

'''
  @arg wait Wait
'''
def VerifyOwner(prompt:str = 'authenticate via Touch ID',
                wait:int = 0) -> bool:
    if(len(prompt)<1):
      raise ValueError("prompt's length must longer than 1.")
    return (VerifyOwnerF(prompt,wait)==0)
