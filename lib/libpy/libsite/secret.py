import os, gpgme

def secret(secret):
    secrets = '%s/.secrets' % os.environ['HOME']
    if os.path.exists(secrets):
        from io import BytesIO
        o = BytesIO()
        with open(secrets, 'r') as ifH:
            from gpgme import Context
            ctx = Context()
            ctx.armor = True
            ctx.decrypt(ifH, o)
        return dict(
            (_.split(None, 1) for _ in o.getvalue().split('\n') if _)
        ).get(secret, '').strip()
