"""Conceptual ownership validator.
Adapt OWNERS below to real GitHub usernames/branches in the project.
"""
from pathlib import Path
OWNERS = {
    'src/Domain/':'AI-02',
    'src/Presentation/':'AI-03',
    'Assets/Art/':'AI-04',
    'Assets/VFX/':'AI-04',
    'Assets/UI/':'AI-05',
    'src/UI/':'AI-05',
    'Assets/Audio/':'AI-06',
    'tests/':'AI-07',
    'QA/':'AI-07',
    '.github/':'AI-08',
    'Release/':'AI-08',
}

def owner_for(path: str):
    for prefix, owner in sorted(OWNERS.items(), key=lambda x:-len(x[0])):
        if path.replace('\\','/').startswith(prefix):
            return owner
    return None

if __name__ == '__main__':
    print('Ownership policy helper. Integrate with CI/GitHub API for enforcement.')
    for k,v in OWNERS.items(): print(v, '->', k)
