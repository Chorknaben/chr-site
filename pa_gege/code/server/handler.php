<?php
class Handler{
    private $result_buffer = array();
    public function __construct(){
        
    }    
    
    public function init_image_dispatch($getarr){
        array_shift($getarr);
        $invalid = false;
        foreach($getarr as $key => $val){
            switch ($key){
                case 'numtiles':
                    if (!$invalid){
                        $this->result_buffer['numtiles'] = $this->image_numtiles();
                    }
                    break;
                default:
                    $invalid = true;
                    break;
            }
        }
        if ($invalid){
            $this->result_buffer = array();
            $this->result_buffer["error"] = "Invalid Argument";
        }
    }
    
    private function image_numtiles(){
        // Anzahl der Kategorien        
        // TODO: sqlite / mysql server oder so...
        $num_categories = 6;
        
        // Anzahl der Bilder
        // Todo Inhalt Ordner zählen
        $num_img = 35;
        
        return $num_categories + $num_img;
    }
    
    public function send_results(){
        echo json_encode($this->result_buffer);
    }
}

$handler = new Handler();
//todo separate requests etc bla bla
switch (key($_GET)){
    case 'img':
        $handler->init_image_dispatch($_GET);    
        break;
    default: break;
}
$handler->send_results();
?>