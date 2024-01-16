#!/bin/python3

###
### Tests for music transfer script functions and behaviors.
###

from music_transfer import (
	munge_path,
)
import unittest

class PathMungingTestCase(unittest.TestCase):
	def test_colon_munging(self):
		self.assertEqual('/Music/Haywyre/Haywyre - Panorama- Form',
			munge_path('/Music/Haywyre/Haywyre - Panorama: Form'))

	def test_asterisk_munging(self):
		self.assertEqual('/Music/Other, Various Artists/P-Light - complexity.flac',
			munge_path('/Music/Other, Various Artists/P*Light - complexity.flac'))

	def test_question_mark_munging(self):
		self.assertEqual('/Music/Other, Various Artists/They Might Be Giants - Am I Awake-.mp3',
			munge_path('/Music/Other, Various Artists/They Might Be Giants - Am I Awake?.mp3'))

	def test_quote_munging(self):
		self.assertEqual('/media/storage0/Documents/My Music/NoteBlock/NoteBlock - -C-R-O-W-N-E-D- Kirby\'s Return to Dreamland Deluxe Remix.opus',
			munge_path('/media/storage0/Documents/My Music/NoteBlock/NoteBlock - "C-R-O-W-N-E-D" Kirby\'s Return to Dreamland Deluxe Remix.opus'))

	def test_emoji_munging(self):
		self.assertEqual('/Music/TORLEY/TORLEY -U0001f349 - Odds & Ends/TORLEY -U0001f349 - Odds & Ends - 30 [PIANO] The Games We Played.flac',
			munge_path('/Music/TORLEY/TORLEY 🍉 - Odds & Ends/TORLEY 🍉 - Odds & Ends - 30 [PIANO] The Games We Played.flac'))

	def test_multiple_munging(self):
		# colon and unicode (U+2019, which resembles backtick)
		self.assertEqual('/Music/Other, Various Artists/AD-Drum-u2019n Bass/AD-Drum-u2019n Bass 01 - Jerico - Industrial Nation.flac',
			munge_path('/Music/Other, Various Artists/AD:Drum’n Bass/AD:Drum’n Bass 01 - Jerico - Industrial Nation.flac'))

		# quote and unicode (Japanese characters)
		self.assertEqual('/Music/Camellia/-u304b-u3081-u308a-u3042 - Camellia -Guest Tracks- Summary & VIPs 01/-u304b-u3081-u308a-u3042 - Camellia -Guest Tracks- Summary & VIPs 01 - 14 Feelin Sky (Camellia\'s -200step- Self-remix).flac',
			munge_path('/Music/Camellia/かめりあ - Camellia "Guest Tracks" Summary & VIPs 01/かめりあ - Camellia "Guest Tracks" Summary & VIPs 01 - 14 Feelin Sky (Camellia\'s ""200step"" Self-remix).flac'))

		# unicode (U+B0, degree symbol)
		self.assertEqual('/Music/Caravan Palace/Caravan Palace - I-xb0_-xb0I',
			munge_path('/Music/Caravan Palace/Caravan Palace - I°_°I'))

		# unicode (U+2606, outlined star symbol)
		self.assertEqual('/Music/Other, Various Artists/Various Artists - SONIC-u2606FRONTLINE v1.0/SONIC-u2606FRONTLINE v1.0 06 - Tanchiky - STEP BY STEP.flac',
			munge_path('/Music/Other, Various Artists/Various Artists - SONIC☆FRONTLINE v1.0/SONIC☆FRONTLINE v1.0 06 - Tanchiky - STEP BY STEP.flac'))

if __name__ == '__main__':
	unittest.main()
