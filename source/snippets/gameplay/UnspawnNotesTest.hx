package snippets.gameplay;

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

typedef Note = {
	strumTime:Float,
	noteData:Int,
	mustPress:Bool,
	noteType:String
}

typedef Conductor = {
	songPosition:Float,
	stepCrochet:Float
}

// This class is needed.
class Paths {
	public static function json(key:String):String {
		return 'assets/data/$key.json';
	}
}

// The unspawn notes snippet. This shows how you can spawn notes without having to preallocate them.
// THIS IS THE FIRST EVER SNIPPET IN THIS REPOSITORY.

class UnspawnNotesTest extends BaseClassSnippet {
	public var UnspawnNotes:Array<ChartNote> = [];
	public var EventNotes:Array<ChartEvent> = [];

	public var camHUD:Dynamic = {zoom = 1.0};

	public var notes:Dynamic = {members = []};
	public var sustains:Dynamic = {members = []};

	public var conductor:Conductor = {songPosition: 0.0, stepCrochet: 100};

	override public function create():Void
	{
		super.create();

		UnspawnNotes = haxe.Json.parse(Paths.json('test/test-hard')).Gameplay.Notes;
		EventNotes = haxe.Json.parse(Paths.json('test/test-hard')).Gameplay.Events;
		UnspawnNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));
		EventNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		while (UnspawnNotes[UnspawnNotes.length - 1] != null
			&& conductor.songPosition > UnspawnNotes[UnspawnNotes.length - 1].StrumTime - (2000 * camHUD.zoom))
		{
			// var nm:NotesGroup = UnspawnNotes[UnspawnNotes.length-1].isSustainNote ? sustains : notes;
			var n:Note = Note.new(UnspawnNotes[UnspawnNotes.length - 1].StrumTime,
				UnspawnNotes[UnspawnNotes.length - 1].NoteData,
				notes.members[notes.members.length - 1],
			false);
			if (UnspawnNotes[UnspawnNotes.length - 1].SustainLength > (conductor.stepCrochet * 1.5))
			{
				for (susNote in 0...Std.int(UnspawnNotes[UnspawnNotes.length - 1].SustainLength / conductor.stepCrochet))
				{
					var n:Note = Note.new(UnspawnNotes[UnspawnNotes.length - 1].StrumTime + (conductor.stepCrochet * (susNote + 1)),
						UnspawnNotes[UnspawnNotes.length - 1].NoteData,
						sustains.members[sustains.members.length - 1],
					true);
					sn.strumTime = UnspawnNotes[UnspawnNotes.length - 1].StrumTime;
					sn.noteData = UnspawnNotes[UnspawnNotes.length - 1].NoteData;
					sn.mustPress = UnspawnNotes[UnspawnNotes.length - 1].MustPress;
					sn.noteType = UnspawnNotes[UnspawnNotes.length - 1].Type;
					sn.parent = n;
					sustains.add(sn);
					sustains.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
				}
			}
			n.strumTime = UnspawnNotes[UnspawnNotes.length - 1].StrumTime;
			n.noteData = UnspawnNotes[UnspawnNotes.length - 1].NoteData;
			n.mustPress = UnspawnNotes[UnspawnNotes.length - 1].MustPress;
			n.noteType = UnspawnNotes[UnspawnNotes.length - 1].Type;
			notes.add(n);
			notes.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
			UnspawnNotes.pop();
		}

		while (EventNotes[EventNotes.length - 1] != null && conductor.songPosition > EventNotes[EventNotes.length - 1].StrumTime)
		{
			var value1:String = '';
			if(EventNotes[EventNotes.length-1].Value1 != null)
				value1 = EventNotes[EventNotes.length-1].Value1;

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