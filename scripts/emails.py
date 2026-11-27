"""Writes the Supabase Auth email templates to email-templates/.
Paste each file into Supabase > Authentication > Emails > (template) > Source."""
import os

LOGO = "https://www.thecardboardclinic.com/assets/logo.png"
SITE = "https://www.thecardboardclinic.com"
GREEN = "#175c59"

def shell(heading, intro, middle, outro):
    return f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="light only"><title>{heading}</title></head>
<body style="margin:0;padding:0;background:#f4f2ec;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f2ec;padding:28px 12px;">
<tr><td align="center">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;background:#ffffff;border:1px solid #e3e1da;">
<tr><td style="padding:28px 32px 8px;"><img src="{LOGO}" alt="Cardboard Clinic" width="150" style="display:block;width:150px;height:auto;border:0;"></td></tr>
<tr><td style="padding:12px 32px 28px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;color:#1f2b2e;font-size:15px;line-height:1.6;">
<h1 style="margin:0 0 12px;font-size:22px;line-height:1.3;color:{GREEN};">{heading}</h1>
<p style="margin:0 0 18px;">{intro}</p>
{middle}
<p style="margin:22px 0 0;color:#6f7b79;font-size:13px;">{outro}</p>
</td></tr>
<tr><td style="padding:18px 32px;border-top:1px solid #eeece6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;font-size:12px;line-height:1.6;color:#8a948f;">
Cardboard Clinic · Trading card repair in Singapore<br>
Questions? WhatsApp us on <a href="https://wa.me/6598221113" style="color:{GREEN};">9822 1113</a> · <a href="{SITE}" style="color:{GREEN};">thecardboardclinic.com</a>
</td></tr>
</table>
</td></tr></table>
</body></html>
"""

def button(label, href="{{ .ConfirmationURL }}"):
    return f"""<table role="presentation" cellpadding="0" cellspacing="0" style="margin:6px 0 10px;"><tr><td style="background:{GREEN};"><a href="{href}" style="display:inline-block;padding:13px 24px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;">{label}</a></td></tr></table>"""

def code_box():
    return f"""<table role="presentation" cellpadding="0" cellspacing="0" style="margin:4px 0 16px;"><tr><td style="background:#eef5f0;border:1px solid #cfe3d6;padding:14px 22px;font-family:'SF Mono',Menlo,Consolas,monospace;font-size:30px;font-weight:700;letter-spacing:8px;color:{GREEN};">{{{{ .Token }}}}</td></tr></table>"""

TEMPLATES = {
 "1-confirm-signup.html": ("Your Cardboard Clinic code",
   shell("Finish creating your account",
         "Enter this code on the website to confirm your email. It works for <strong>3 minutes</strong>.",
         code_box() + "<p style=\"margin:0 0 8px;\">Or tap the button instead:</p>" + button("Confirm my email"),
         "If you didn't create an account with Cardboard Clinic, you can ignore this email.")),
 "2-invite-user.html": ("You're invited to Cardboard Clinic",
   shell("You're invited",
         "You've been invited to a Cardboard Clinic account. Tap below to accept and set your password.",
         button("Accept invitation"),
         "If you weren't expecting this, you can ignore this email.")),
 "3-magic-link.html": ("Your Cardboard Clinic sign-in link",
   shell("Sign in to Cardboard Clinic",
         "Tap the button below to sign in. The link works once and expires soon.",
         button("Sign in"),
         "If you didn't ask to sign in, you can ignore this email. Your account is safe.")),
 "4-change-email.html": ("Confirm your new email address",
   shell("Confirm your new email",
         "You asked to change your Cardboard Clinic email from <strong>{{ .Email }}</strong> to <strong>{{ .NewEmail }}</strong>. Tap below to confirm.",
         button("Confirm new email"),
         "If you didn't ask for this change, WhatsApp us on 9822 1113 and we'll check your account.")),
 "5-reset-password.html": ("Reset your Cardboard Clinic password",
   shell("Reset your password",
         "We got a request to reset the password for <strong>{{ .Email }}</strong>. Tap below to choose a new one.",
         button("Choose a new password"),
         "If you didn't ask for this, you can ignore this email. Your password stays the same.")),
 "6-reauthentication.html": ("Your Cardboard Clinic security code",
   shell("Confirm it's you",
         "Enter this code to confirm the change to your account.",
         code_box(),
         "If you didn't ask for this, you can ignore this email.")),
}

os.makedirs("email-templates", exist_ok=True)
readme = ["Supabase email templates for Cardboard Clinic",
          "Paste each one into Supabase > Authentication > Emails > (template name) > Source, and set the Subject.", ""]
names = {"1": "Confirm signup", "2": "Invite user", "3": "Magic link", "4": "Change email address", "5": "Reset password", "6": "Reauthentication"}
for fn, (subject, body) in TEMPLATES.items():
    open(f"email-templates/{fn}", "w").write(body)
    readme.append(f"{names[fn[0]]:<22} subject: {subject:<40} file: {fn}")
open("email-templates/README.txt", "w").write("\n".join(readme) + "\n")
print("\n".join(readme))
