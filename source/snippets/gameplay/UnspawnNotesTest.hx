package snippets.gameplay;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;

enum abstract ChartEventType(String) from String to String {
	var TEMPO:String = 'tempo';
	var GAMEPLAY:String = 'gameplay';
	var SCRIPTED:String = 'scripted';
}

typedef ChartNote = {
	StrumTime:Float,
	NoteData:Int,
	SustainLength:Float,
	Type:String,
	MustPress:Bool
}

typedef ChartEvent = {
	Type:ChartEventType,
	Name:String,
	Value1:String,
	?Value2:String,
	?Value3:String,
	Offset:Float,
	StrumTime:Float
}

class Note extends flixel.FlxBasic {
	public var strumTime:Float = 0.0;
	public var noteData:Int = 0;
	public var mustPress:Bool = true;
	public var noteType:String = '';

	public var isSustainNote:Bool = false;
	public var sustainLength:Float = 0.0;
	public var tail:Array<Note> = [];

	public var prevNote:Null<Note> = null;
	public var parent:Null<Note> = null;

	public function new(time:Float, data:Int, lastNote:Note = null, sustainNote:Bool = false):Void {
		super();

		strumTime = time;
		noteData = data;
		prevNote = lastNote;
		isSustainNote = sustainNote;
	}
}

// The unspawn notes snippet. This shows how you can spawn notes without having to preallocate them, which saves on loading times.
// THIS IS THE FIRST EVER SNIPPET IN THIS REPOSITORY.

class UnspawnNotesTest extends BaseClassSnippet {
	public var SpawnTime:Float = 2000.0;

	public var UnspawnNotes:Array<ChartNote> = [];
	public var EventNotes:Array<ChartEvent> = [];

	public var Notes:FlxTypedGroup<Note>;
	public var Sustains:FlxTypedGroup<Note>;

	public var Conductor:{songPosition:Float, stepCrochet:Float} = {songPosition: 0.0, stepCrochet: 100.0}; // This won't be included in the final snippet, this is just a placeholder

	override public function create():Void
	{
		super.create();

		Notes = new FlxTypedGroup<Note>();
		Sustains = new FlxTypedGroup<Note>();
		add(Notes);
		add(Sustains);

		var P:{Gameplay:{Notes:Array<ChartNote>, Events:Array<ChartEvent>}} = haxe.Json.parse(sys.io.File.getContent('assets/data/test/test-sustain.json'));
		UnspawnNotes = P.Gameplay.Notes;
		EventNotes = P.Gameplay.Events;
		UnspawnNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));
		EventNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));

		flixel.FlxG.sound.playMusic('assets/music/Inst.ogg', 1.0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		Conductor.songPosition = flixel.FlxG.sound.music.time;

		while (UnspawnNotes[UnspawnNotes.length - 1] != null && (Conductor.songPosition > UnspawnNotes[UnspawnNotes.length - 1].StrumTime))
		{
			var n:Note = new Note(UnspawnNotes[UnspawnNotes.length - 1].StrumTime,
				UnspawnNotes[UnspawnNotes.length - 1].NoteData,
				Notes.members[Notes.members.length - 1], false);
			n.mustPress = UnspawnNotes[UnspawnNotes.length - 1].MustPress;
			n.noteType = UnspawnNotes[UnspawnNotes.length - 1].Type;
			n.sustainLength = UnspawnNotes[UnspawnNotes.length - 1].SustainLength;
			if (Notes.members.contains(n)) {
				var sn:Note = new Note(n.strumTime + (Conductor.stepCrochet * (n.tail.length + 1)), n.noteData,
					Sustains.members[Notes.members.length - 1], false);
				Sustains.add(n);
				Sustains.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
				n.tail.push(n);
				n.tail.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
				trace('spawned sus note ${Notes.members[Notes.members.length - 1].tail.length} at ${sn.strumTime}');
				if (n.tail.length == Std.int(n.sustainLength / Conductor.stepCrochet)) break;
				continue;
			}
			Notes.add(n);
			Notes.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
			trace('spawned note ${UnspawnNotes.length - 1} at ${n.strumTime}');
			UnspawnNotes.pop();
		}

		/*while (Notes.members[Notes.members.length - 1] != null && Notes.members[Notes.members.length - 1].sustainLength > Conductor.stepCrochet * 1.5 && 
			Notes.members[Notes.members.length - 1].tail.length < Std.int(UnspawnNotes[UnspawnNotes.length - 1].SustainLength / Conductor.stepCrochet)) {

		}*/

		while (EventNotes[EventNotes.length - 1] != null && Conductor.songPosition > EventNotes[EventNotes.length - 1].StrumTime)
		{
			var Value1:String = '';
			if(EventNotes[EventNotes.length-1].Value1 != null)
				Value1 = EventNotes[EventNotes.length-1].Value1;

			var Value2:String = '';
			if(EventNotes[EventNotes.length-1].Value2 != null)
				Value2 = EventNotes[EventNotes.length-1].Value2;

			var Value3:String = '';
			if(EventNotes[EventNotes.length-1].Value3 != null)
				Value3 = EventNotes[EventNotes.length-1].Value3;

			triggerEventNote(EventNotes.pop(), Value1, Value2, Value3);
		}
	}

	dynamic function triggerEventNote(event:ChartEvent, v1:String, v2:String, v3:String):Void
	{
		switch (event.Name)
		{
			case "Change BPM":
				if (event.Type == TEMPO)
				{
					// Change BPM to Std.parseFloat(v1)
				}
		}
	}
}