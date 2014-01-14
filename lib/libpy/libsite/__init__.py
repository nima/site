#. External (via PIP) Libraries
import os
VENV_ACTIVATE = os.path.join(
    os.path.expanduser("~/.site"),
    os.environ["SITE_CORE_EXTERN"],
    "venv/bin/activate_this.py"
)
execfile(VENV_ACTIVATE, dict(__file__=VENV_ACTIVATE))
