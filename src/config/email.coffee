
config =
  locals:
    logo_src: '/images/logo-email.gif'
    logo_width: 194
    logo_height: 76
    theme:
      email_bg: '#f9f9f9'
      link_color: '#2697de'
      buttons:
        color: '#fff'
        background_color: '#2697de'
        border_color: '#1a7cb7'
  actions:
    register:
      template: 'welcome'
      requiredFields: subject: 'subject', link: 'link', name: 'user.email'
    recover:
      template: 'recover-password'
      requiredFields:
        subject: 'subject'
        link: 'link'
        avatar: 'user.avatar'
        name: 'user.email'
    confirm:
      template: 'email-confirmed'
      requiredFields: subject: 'subject', link: 'link', name: 'user.email'

module.exports = exports = config