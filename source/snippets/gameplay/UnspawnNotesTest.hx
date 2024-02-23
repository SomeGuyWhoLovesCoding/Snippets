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

typedef Conductor = {
	songPosition:Float,
	stepCrochet:Float
}

// The unspawn notes snippet. This shows how you can spawn notes without having to preallocate them, which saves on loading times.
// THIS IS THE FIRST EVER SNIPPET IN THIS REPOSITORY.

class UnspawnNotesTest extends BaseClassSnippet {
	public var UnspawnNotes:Array<ChartNote> = [];
	public var EventNotes:Array<ChartEvent> = [];

	public var camHUD:{zoom:Float} = {zoom: 1.0};

	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<Note>;

	public var conductor:Conductor = {songPosition: 0.0, stepCrochet: 100.0};

	override public function create():Void
	{
		super.create();

		notes = new FlxTypedGroup<Note>();
		sustains = new FlxTypedGroup<Note>();
		add(notes);
		add(sustains);

		var P:{Gameplay:{Notes:Array<ChartNote>, Events:Array<ChartEvent>}} = haxe.Json.parse(sys.io.File.getContent('assets/data/test/test-hard.json'));
		UnspawnNotes = P.Gameplay.Notes;
		EventNotes = P.Gameplay.Events;
		UnspawnNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));
		EventNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));

		flixel.FlxG.sound.playMusic('assets/music/Inst.ogg', 1.0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.songPosition = flixel.FlxG.sound.music.time;

		while (UnspawnNotes[UnspawnNotes.length - 1] != null
			&& conductor.songPosition > UnspawnNotes[UnspawnNotes.length - 1].StrumTime - (2000))
		{
			// var nm:NotesGroup = UnspawnNotes[UnspawnNotes.length-1].isSustainNote ? sustains : notes;
			var n:Note = new Note(UnspawnNotes[UnspawnNotes.length - 1].StrumTime, UnspawnNotes[UnspawnNotes.length - 1].NoteData, notes.members[notes.members.length - 1], false);
			if (UnspawnNotes[UnspawnNotes.length - 1].SustainLength > (conductor.stepCrochet * 1.5))
			{
				for (susNote in 0...Std.int(UnspawnNotes[UnspawnNotes.length - 1].SustainLength / conductor.stepCrochet))
				{
					var sn:Note = new Note(UnspawnNotes[UnspawnNotes.length - 1].StrumTime + (conductor.stepCrochet * (susNote + 1)), UnspawnNotes[UnspawnNotes.length - 1].NoteData, sustains.members[sustains.members.length - 1], true);
					sn.mustPress = UnspawnNotes[UnspawnNotes.length - 1].MustPress;
					sn.noteType = UnspawnNotes[UnspawnNotes.length - 1].Type;
					sn.parent = n;
					sustains.add(sn);
					sustains.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
					trace('spawned sus note $susNote at ${sn.strumTime}');
				}
			}
			n.mustPress = UnspawnNotes[UnspawnNotes.length - 1].MustPress;
			n.noteType = UnspawnNotes[UnspawnNotes.length - 1].Type;
			n.sustainLength = UnspawnNotes[UnspawnNotes.length - 1].SustainLength;
			notes.add(n);
			notes.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
			UnspawnNotes.pop();
		}

		while (EventNotes[EventNotes.length - 1] != null && conductor.songPosition > EventNotes[EventNotes.length - 1].StrumTime)
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