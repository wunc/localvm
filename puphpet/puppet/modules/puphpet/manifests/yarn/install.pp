class puphpet::yarn::install {

  include ::puphpet::params

  class { '::yarn': }

}