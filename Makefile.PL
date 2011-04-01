use inc::Module::Install;
  
# Define metadata
name           'CollabIRCate';
  
# Specific dependencies
requires       'Mojolicious' => '1.15';
requires       'HTML::FormFu' => 0;
requires       'Rose::DB' => 0;
requires       'Rose::DB::Object' => 0;
requires       'DBI' => '1.616';

# test_requires  'Test::More'  => '0.42';
recommends     'Hailo'=> '0.64';

license        'perl';

tests_recursive;

version        '0.04';

WriteAll;
