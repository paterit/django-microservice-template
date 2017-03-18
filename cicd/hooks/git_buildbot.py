from git import Repo
import os

repo = Repo(os.getcwd())
assert not repo.bare

hcommit = repo.head.commit


ret_msg = ""
ret_msg += "export DMT_GIT_AUTHOR='%s <%s>'\n" % (hcommit.author.name, hcommit.author.email)
ret_msg += "export DMT_GIT_MSG='%s'\n" % (hcommit.message)
ret_msg += "export DMT_GIT_FILES='%s'\n" % (" ".join(hcommit.stats.files.keys()))
ret_msg += "export DMT_GIT_REVISION='%s'\n" % (hcommit.name_rev.split(" ")[0])
try:
    ret_msg += "export DMT_GIT_REPO='%s'\n" % (repo.remote())
except ValueError:
    ret_msg += "export DMT_GIT_REPO='%s'\n" % (repo.working_dir)

#set category for initial commit to allow buildbot do fullrebuild for the first time
category = "quick_tests"
if (len(repo.head.log()) == 1):
    category = "full_rebuild"

ret_msg += "export DMT_GIT_CATEGORY='%s'\n" % (category)

print(ret_msg)
