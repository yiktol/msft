class iis(
){
  # Install the IIS role
  dsc_windowsfeature {'IIS':
    dsc_ensure => 'present',
    dsc_name   => 'Web-Server',
  } ->

  # Install the ASP .NET 4.5 role
  dsc_windowsfeature {'AspNet45':
    dsc_ensure => 'present',
    dsc_name   => 'Web-Asp-Net45',
  } ->

  # Start IIS
  dsc_xwebsite {'Stop DefaultSite':
    dsc_ensure       => 'present',
    dsc_name         => 'Default Web Site',
    dsc_state        => 'Started',
  }
}
