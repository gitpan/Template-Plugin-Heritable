use inc::Module::Install;

name            ('Template-Plugin-Heritable');
abstract        ('OO dispatching and inheritance for templates');
author          ('Sam Vilain <samv@cpan.org>');
version_from    ('lib/Template/Plugin/Heritable.pm');
license         ('perl');

requires        ('perl' => 5.005);
requires        ('Template' => 2);

recommends      ('T2' => 0.10);
#recommends      ('Perl6::MetaModel' => 0);

build_requires  ('Test::More');

include ("Test::Depends" => 0.05);

#tests           ('mytest.pl');
#sign

&WriteAll;
