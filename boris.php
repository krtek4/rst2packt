#!/usr/bin/env php
<?php

// This won't work if the directory structure is different
require_once __DIR__ . '/../src/vendor/autoload.php';

function exception_handler($e) {
    $type = get_class($e);
    echo '// PHP Fatal error: Uncaught '.$type.': '.$e->getMessage()."\n";
}

function error_handler($errno , $errstr) {
    echo '// ERROR: '.$errstr."\n\n";
}

set_exception_handler('exception_handler');
set_error_handler('error_handler');

class FullInspector extends \Boris\Inspector
{
    private $statement;

    public function isInspectable($input) {
        return true;
    }

    public function makeInspectable($input) {
        $this->statement = str_replace(static::MAGIC, '', $input);
        return $this->statement;
    }

    public function inspect($variable, $output)
    {
        $content = $this->statement;

        $output = trim($output.'');
        if(strlen($output) > 0) {
            $output = explode("\n", $output);
            $output = array_map(function($l) {
              return '// '.$l;
            }, $output);
            $output = implode("\n", $output);

            $content = sprintf("%s%s", $content, $output);
        }

        return $content;
    }
}

$boris = new \Boris\Boris();
$boris->setInspector(new FullInspector());

$boris->start();
