package fnf.backend.interfaces;

interface INoteTriggers {
    function noteHit(event:NoteHitEvent):Void;
    function noteMiss(event:NoteMissEvent):Void;
    function generalMiss(event:MissEvent):Void;
}