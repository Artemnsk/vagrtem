name 'drupal_build'
version "1.0.0"

# DEPENDENCIES.
depends 'apache2', '~> 3.2.2'
depends 'php', '~> 2.2.0'
# Needed for php.
depends 'iis', '~> 5.0.5'
  # Needed for iis.
  depends 'windows', '~> 2.1.1'
    # Needed for windows.
    depends'ohai', '~> 4.2.3'
      # Needed for ohai, yum-epel, build-essential, mingw, apt.
      depends 'compat_resource', '~> 12.16.3'
depends 'yum-epel', '~> 2.1.1'
depends 'mysql', '~> 8.2.0'
depends 'xml', '~> 3.1.1'
  # Needed for xml.
  depends 'build-essential', '~> 7.0.3'
    # Needed for build-essential.
    depends 'mingw', '~> 1.2.5'
      # Needed for mingw.
      depends 'seven_zip', '~> 2.0.2'
depends 'nodejs', '~> 3.0.0'
  # Needed for nodejs.
  depends 'homebrew', '~> 3.0.0'
  depends 'apt', '~> 5.0.1'
  depends 'ark', '~> 2.2.1'