class Index extends App.ControllerContent
  className: 'login fit vertical center justified'
  
  events:
    'submit #login': 'login'

  constructor: ->
    super

    # navigate to # if session if exists
    if @Session.get( 'id' )
      @navigate '#'
      return

    @title 'Sign in'
    @render()
    @navupdate '#login'

  render: (data = {}) ->
    auth_provider_all = {
      facebook: {
        url:    '/auth/facebook',
        name:   'Facebook',
        config: 'auth_facebook',
      },
      twitter: {
        url:    '/auth/twitter',
        name:   'Twitter',
        config: 'auth_twitter',
      },
      linkedin: {
        url:    '/auth/linkedin',
        name:   'LinkedIn',
        config: 'auth_linkedin',
      },
      google_oauth2: {
        url:    '/auth/google_oauth2',
        name:   'Google',
        config: 'auth_google_oauth2',
      },
    }
    auth_providers = []
    for key, provider of auth_provider_all
      if @Config.get( provider.config ) is true || @Config.get( provider.config ) is "true"
        auth_providers.push provider

    @html App.view('login')(
      item:           data
      auth_providers: auth_providers
    )

    # set focus to username or password
    if !$(@el).find('[name="username"]').val()
      $(@el).find('[name="username"]').focus()
    else
      $(@el).find('[name="password"]').focus()

    # scroll to top
    @scrollTo()

  login: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @formDisable(e)
    params = @formParam(e.target)

    # remember username
    @username = params['username']

    # session create with login/password
    App.Auth.login(
      data:    params
      success: @success
      error:   @error
    )

  success: (data, status, xhr) =>

    # rebuild navbar with ticket overview counter
    App.WebSocket.send( event: 'navupdate_ticket_overview' )

    # add notify
    @notify
      type:      'success'
      msg:       App.i18n.translateContent('Login successfully! Have a nice day!')
      removeAll: true

    # redirect to #
    requested_url = @Config.get( 'requested_url' )
    if requested_url && requested_url isnt '#login'
      @log 'notice', "REDIRECT to '#{requested_url}'"
      @navigate requested_url

      # reset
      @Config.set( 'requested_url', '' )
    else
      @log 'notice', "REDIRECT to -#/-"
      @navigate '#/'

  error: (xhr, statusText, error) =>

    # add notify
    @notify
      type:      'error'
      msg:       App.i18n.translateContent('Wrong Username and Password combination.')
      removeAll: true

    # rerender login page
    @render(
      username: @username
    )

    # login shake
    @delay(
      => @shake( @el.find('#login') ),
      600
    )

App.Config.set( 'login', Index, 'Routes' )
