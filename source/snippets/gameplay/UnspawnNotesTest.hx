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
	public var unspawnNotes:Array<ChartNote> = [];
	public var eventNotes:Array<ChartEvent> = [];

	public var camHUD:Dynamic = {zoom = 1.0};

	public var notes:Dynamic = {members = []};
	public var sustains:Dynamic = {members = []};

	public var conductor:Conductor = {songPosition: 0.0, stepCrochet: 100};

	override public function create():Void
	{
		super.create();

		unspawnNotes = haxe.Json.parse(Paths.json('test/test-hard')).Gameplay.Notes;
		eventNotes = haxe.Json.parse(Paths.json('test/test-hard')).Gameplay.Events;
		unspawnNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));
		eventNotes.sort((b, a) -> Std.int(a.StrumTime - b.StrumTime));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		while (unspawnNotes[unspawnNotes.length - 1] != null
			&& conductor.songPosition > unspawnNotes[unspawnNotes.length - 1].StrumTime - (2000 * camHUD.zoom))
		{
			// var nm:NotesGroup = unspawnNotes[unspawnNotes.length-1].isSustainNote ? sustains : notes;
			var n:Note = Note.new(unspawnNotes[unspawnNotes.length - 1].StrumTime,
				unspawnNotes[unspawnNotes.length - 1].NoteData,
				notes.members[notes.members.length - 1],
			false);
			for (susNote in 0...Std.int(unspawnNotes[unspawnNotes.length - 1].SustainLength / conductor.stepCrochet))
			{
				var n:Note = Note.new(unspawnNotes[unspawnNotes.length - 1].StrumTime + (conductor.stepCrochet * (susNote + 1)),
					unspawnNotes[unspawnNotes.length - 1].NoteData,
					sustains.members[sustains.members.length - 1],
				true);
				sn.strumTime = unspawnNotes[unspawnNotes.length - 1].StrumTime;
				sn.noteData = unspawnNotes[unspawnNotes.length - 1].NoteData;
				sn.mustPress = unspawnNotes[unspawnNotes.length - 1].MustPress;
				sn.noteType = unspawnNotes[unspawnNotes.length - 1].Type;
				sn.parent = n;
				sustains.add(sn);
				sustains.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
			}
			n.strumTime = unspawnNotes[unspawnNotes.length - 1].StrumTime;
			n.noteData = unspawnNotes[unspawnNotes.length - 1].NoteData;
			n.mustPress = unspawnNotes[unspawnNotes.length - 1].MustPress;
			n.noteType = unspawnNotes[unspawnNotes.length - 1].Type;
			notes.add(n);
			notes.members.sort((b, a) -> Std.int(a.strumTime - b.strumTime));
			unspawnNotes.pop();
		}

		while (eventNotes[eventNotes.length - 1] != null && conductor.songPosition > eventNotes[eventNotes.length - 1].StrumTime) {
			var value1:String = '';
			if(eventNotes[eventNotes.length-1].Value1 != null)
				value1 = eventNotes[eventNotes.length-1].Value1;

			var value2:String = '';
			if(eventNotes[eventNotes.length-1].Value2 != null)
				value2 = eventNotes[eventNotes.length-1].Value2;

			var value2:String = '';
			if(eventNotes[eventNotes.length-1].Value3 != null)
				value2 = eventNotes[eventNotes.length-1].Value3;

			triggerEventNote(eventNotes.pop(), value1, value2, value3);
		}
	}

	dynamic function triggerEventNote(e:ChartEvent, v1:String, v2:String, v3:String):Void {
		switch(e.Name) {
			case "Change BPM":
				if (e.Type == TEMPO) {
					// Change BPM
				}
		}
	}
}