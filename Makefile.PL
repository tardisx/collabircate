# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'CollabIRCate';

requires 'Mojolicious';
requires 'SQL::Translator';

requires 'Module::Pluggable';
requires 'REST::Google';

requires 'DateTime';
requires 'DateTime::Format::SQLite';
requires 'Path::Class';
requires 'FindBin';
requires 'Mail::Send';
requires 'MIME::Parser';
requires 'URI::Find';

requires 'File::Temp' => 0.18;

requires 'POE' => 1.006;
requires 'POE::Component::IRC' => 6.08;
requires 'POE::Component::Server::IRC';

requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

catalyst;

install_script glob('script/*.pl');
auto_install;
my $tests = join (' ', glob("t/*.t"), glob("t/*/*.t"));
WriteMakefile(test => {TESTS => $tests});
