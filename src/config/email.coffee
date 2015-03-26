###
# Email config:
# locals: Mandrill locals #TODO
# events.properties: describes all configuration (template and requiredFields)
# for each notification.
# - template: Mandrill template name
# - requiredFields is a object that contains a key/path properties.
#   In utils there are a function (utils.resolve) that change the path by
#   value in the path
#   If path is an array:
#     name: ['user.name', 'user.email'] --> name: 'user.name' || 'user.email'
###
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
  events:
    properties:
      register:
        template: 'welcome'
        requiredFields: link: 'vars.link', name: ['user.name', 'user.email']
      confirm:
        template: 'email-confirmed'
        requiredFields: name: ['user.name', 'user.email']
      recoverPassword:
        template: 'recover-password'
        requiredFields: link: 'vars.link', name: ['user.name', 'user.email']
      confirmPassword:
        template: 'password-confirmed'
        requiredFields: name: ['user.name', 'user.email']

module.exports = exports = config