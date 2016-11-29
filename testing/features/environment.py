from selenium import webdriver

BEHAVE_DEBUG_ON_ERROR = False


def before_all(context):
    context.browser = webdriver.PhantomJS()


def after_all(context):
    context.browser.quit()


def after_step(context, step):
    if BEHAVE_DEBUG_ON_ERROR and step.status == "failed":
        # -- ENTER DEBUGGER: Zoom in on failure location.
        # NOTE: Use IPython debugger, same for pdb (basic python debugger).
        import ipdb
        ipdb.post_mortem(step.exc_traceback)
