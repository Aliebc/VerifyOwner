import sys
import VerifyOwner

if len(sys.argv)==1:
  print("VerifyOwner " + VerifyOwner.__version__)
  print("Usage: (python) -m VerifyOwner [prompt]")
else:
  print(VerifyOwner.VerifyOwner(sys.argv[1]))
