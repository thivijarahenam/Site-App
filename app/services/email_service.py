"""SMTP delivery for account invitation and password reset links."""

import smtplib
import ssl
from email.message import EmailMessage
from html import escape

from app.core.config import settings


def _send(recipient: str, subject: str, title: str, intro: str, link: str, expiry: str) -> None:
    if not settings.mailtrap_username or settings.mailtrap_password is None:
        raise RuntimeError("SMTP credentials are not configured")

    brand = escape(settings.mail_from_name)
    safe_title = escape(title)
    safe_intro = escape(intro)
    safe_link = escape(link, quote=True)
    message = EmailMessage()
    message["Subject"] = subject
    message["From"] = f"{settings.mail_from_name} <{settings.mail_from}>"
    message["To"] = recipient
    message.set_content(
        f"{title}\n\n{intro}\n\nOpen this link in the {settings.mail_from_name} app:\n"
        f"{link}\n\nThis link expires in {expiry} and can only be used once.\n\n"
        "If you did not request this, you can safely ignore this email.\n\n"
        f"Regards,\n{settings.mail_from_name} Security Team"
    )
    message.add_alternative(
        f"""<!doctype html>
<html lang="en">
  <body style="margin:0;padding:32px 16px;background:#f3f5f8;
    font-family:Arial,Helvetica,sans-serif;color:#172033;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0"
      style="max-width:560px;margin:0 auto;background:#ffffff;border-radius:12px;">
      <tr><td style="padding:32px 36px 24px;">
        <p style="margin:0 0 10px;color:#53627a;font-size:12px;
          font-weight:700;letter-spacing:1.2px;">{brand.upper()}</p>
        <h1 style="margin:0;font-size:24px;line-height:1.3;">{safe_title}</h1>
        <p style="margin:18px 0 24px;color:#46536a;font-size:15px;line-height:1.6;">{safe_intro}</p>
        <p style="margin:0 0 24px;"><a href="{safe_link}"
          style="display:inline-block;padding:14px 24px;background:#2457c5;
          border-radius:8px;color:#ffffff;text-decoration:none;font-size:15px;
          font-weight:700;">{safe_title}</a></p>
        <p style="margin:0;color:#53627a;font-size:14px;line-height:1.6;">
          This link expires in <strong>{escape(expiry)}</strong> and can only be used once.
        </p>
        <p style="margin:18px 0 0;color:#53627a;font-size:14px;line-height:1.6;">
          If you did not request this, you can safely ignore this email.
        </p>
      </td></tr>
      <tr><td style="padding:20px 36px 30px;border-top:1px solid #edf0f5;">
        <p style="margin:0;color:#7b8799;font-size:12px;line-height:1.6;">
          If the button does not open the app, copy and paste this link into your device:
        </p>
        <p style="overflow-wrap:anywhere;color:#53627a;font-size:12px;
          line-height:1.6;">{safe_link}</p>
        <p style="margin:14px 0 0;color:#7b8799;font-size:12px;">{brand} Security Team</p>
      </td></tr>
    </table>
  </body>
</html>
""",
        subtype="html",
    )

    with smtplib.SMTP(settings.mailtrap_host, settings.mailtrap_port, timeout=10) as smtp:
        smtp.ehlo()
        smtp.starttls(context=ssl.create_default_context())
        smtp.ehlo()
        smtp.login(settings.mailtrap_username, settings.mailtrap_password.get_secret_value())
        smtp.send_message(message)


def send_password_reset_email(recipient: str, link: str) -> None:
    """Send a short-lived link to reset an account password."""
    _send(
        recipient,
        "Reset your password",
        "Reset your password",
        f"Use the secure link below to reset your {settings.mail_from_name} password.",
        link,
        f"{settings.password_reset_link_minutes} minutes",
    )


def send_account_invitation_email(recipient: str, role: str, link: str) -> None:
    """Invite a newly created account holder to set their own password."""
    _send(
        recipient,
        f"Your {settings.mail_from_name} account is ready",
        "Finish setting up your account",
        f"An administrator created a {role} account for you. "
        "Open the secure link to choose your password.",
        link,
        f"{settings.account_invitation_link_hours} hours",
    )


def send_otp_email(recipient: str, otp_code: str, expiry_minutes: int = 10) -> None:
    """Send a secure 6-digit verification OTP code."""
    if not settings.mailtrap_username or settings.mailtrap_password is None:
        return

    brand = escape(settings.mail_from_name)
    message = EmailMessage()
    message["Subject"] = f"{otp_code} is your {settings.mail_from_name} verification code"
    message["From"] = f"{settings.mail_from_name} <{settings.mail_from}>"
    message["To"] = recipient
    message.set_content(
        f"Your verification code is: {otp_code}\n\n"
        f"Enter this 6-digit code to verify your {settings.mail_from_name} account.\n"
        f"This code will expire in {expiry_minutes} minutes.\n\n"
        "If you did not request this verification, please ignore this message.\n\n"
        f"Regards,\n{settings.mail_from_name} Security Team"
    )
    message.add_alternative(
        f"""<!doctype html>
<html lang="en">
  <body style="margin:0;padding:32px 16px;background:#f3f5f8;
    font-family:Arial,Helvetica,sans-serif;color:#172033;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0"
      style="max-width:560px;margin:0 auto;background:#ffffff;border-radius:12px;">
      <tr><td style="padding:32px 36px 24px;">
        <p style="margin:0 0 10px;color:#53627a;font-size:12px;
          font-weight:700;letter-spacing:1.2px;">{brand.upper()}</p>
        <h1 style="margin:0;font-size:24px;line-height:1.3;">Verify Your Account</h1>
        <p style="margin:18px 0 24px;color:#46536a;font-size:15px;line-height:1.6;">
          Thank you for signing up. Please enter the following 6-digit verification code:
        </p>
        <div style="margin:0 0 24px;padding:16px 24px;background:#f0f4ff;border-radius:8px;
          text-align:center;letter-spacing:8px;font-size:32px;font-weight:700;color:#2457c5;">
          {escape(otp_code)}
        </div>
        <p style="margin:0;color:#53627a;font-size:14px;line-height:1.6;">
          This code expires in <strong>{expiry_minutes} minutes</strong>.
          Do not share this code with anyone.
        </p>
      </td></tr>
    </table>
  </body>
</html>
""",
        subtype="html",
    )

    try:
        with smtplib.SMTP(settings.mailtrap_host, settings.mailtrap_port, timeout=10) as smtp:
            smtp.ehlo()
            smtp.starttls(context=ssl.create_default_context())
            smtp.ehlo()
            smtp.login(settings.mailtrap_username, settings.mailtrap_password.get_secret_value())
            smtp.send_message(message)
    except Exception:
        pass

