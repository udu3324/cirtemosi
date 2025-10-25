# Leaderboard.gd (tysm <3 https://github.com/NanoMars/space-game/blob/main/game/UI/win_screen/leaderboard.gd)
extends Node
class_name Leaderboard
@onready var http: HTTPRequest = HTTPRequest.new()

const BASE := "https://jeohnkxktqlqkurstytt.supabase.co/rest/v1"
const TABLE := "scores"
const API_KEY := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Implb2hua3hrdHFscWt1cnN0eXR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzMzU4NjksImV4cCI6MjA3NjkxMTg2OX0.B9x2habRggD6uVAJP4QhD6PuHXQtjAP0vwK89fH-Ggk"  # safe to ship with RLS

#
# Use explicit PackedStringArray constants (no concatenation),
# so they are valid constant expressions in GDScript.
const HEADERS_GET: PackedStringArray = [
	"apikey: " + API_KEY,
	"Authorization: Bearer " + API_KEY
]

const HEADERS_POST: PackedStringArray = [
	"apikey: " + API_KEY,
	"Authorization: Bearer " + API_KEY,
	"Content-Type: application/json"
]

signal leaderboard_request_completed(data)

enum RequestKind { NONE, SUBMIT, FETCH }
var _request_kind: int = RequestKind.NONE
var _pending_limit: int = 50
var _queued_fetch: bool = false

func _ready():
	add_child(http)
	http.accept_gzip = false
	http.request_completed.connect(_on_request_completed)

# Submit a score, then automatically fetch the top results when done.
func submit_score(player_name: String, time: float, wave: int, shards: int, easy_mode: bool) -> void:
	if not http or not is_instance_valid(http):
		push_error("HTTPRequest not ready yet.")
		return
	if _request_kind != RequestKind.NONE:
		push_error("Leaderboard busy; please wait for current request to finish.")
		return
	_request_kind = RequestKind.SUBMIT
	var body = {
		"player_name": player_name,
		"time": time,
		"wave": wave,
		"shards": shards,
		"easy_mode": easy_mode
	}
	var err = http.request(
		"%s/%s" % [BASE, TABLE],
		HEADERS_POST,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		_request_kind = RequestKind.NONE
		push_error("HTTPRequest error: %s" % err)

# Queue or perform a fetch of top scores.
func fetch_top(limit: int = 50) -> void:
	if not http or not is_instance_valid(http):
		push_error("HTTPRequest not ready yet.")
		return
	_pending_limit = limit
	if _request_kind != RequestKind.NONE:
		# Defer until current request completes.
		_queued_fetch = true
		return
	_request_kind = RequestKind.FETCH
	var url = "%s/%s?select=*&order=wave.desc,time.asc&limit=%d" % [BASE, TABLE, limit]
	var err = http.request(url, HEADERS_GET, HTTPClient.METHOD_GET)
	if err != OK:
		_request_kind = RequestKind.NONE
		push_error("HTTPRequest error: %s" % err)

# Handle responses for both POST and GET.
func _on_request_completed(result, response_code, _headers, body):
	var kind := _request_kind
	_request_kind = RequestKind.NONE
	if result != HTTPRequest.RESULT_SUCCESS:
		# If a fetch was queued, try it now even after failure.
		if _queued_fetch:
			_queued_fetch = false
			fetch_top(_pending_limit)
		return

	var text: String = body.get_string_from_utf8()
	if text.is_empty():
		# Still allow a queued fetch.
		if _queued_fetch:
			_queued_fetch = false
			fetch_top(_pending_limit)
		return

	var data = JSON.parse_string(text)

	# After a successful submit, trigger the fetch (or honor a queued fetch).
	if kind == RequestKind.SUBMIT:
		# Always fetch top after submitting.
		fetch_top(_pending_limit)
		return

	# On fetch, emit the leaderboard data.
	if kind == RequestKind.FETCH:
		_queued_fetch = false
		leaderboard_request_completed.emit(data)
