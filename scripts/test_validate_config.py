import unittest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "plugins" / "pstack" / "scripts"))

from validate_config import PANEL_ROLES, SINGLE_ROLES, validate


def valid_config():
    roles = {role: "Codex" for role in SINGLE_ROLES}
    roles.update({role: ["Codex", "Claude Code"] for role in PANEL_ROLES})
    return {
        "families": {"Codex": "openai", "Claude Code": "claude"},
        "roles": roles,
    }


class ConfigValidationTests(unittest.TestCase):
    def test_accepts_available_cross_family_panel(self):
        self.assertEqual(validate(valid_config(), {"Codex", "Claude Code"}), [])

    def test_rejects_unavailable_preset(self):
        self.assertIn("preset is not available", " ".join(validate(valid_config(), {"Codex"})))

    def test_rejects_unmapped_panel_seat(self):
        config = valid_config()
        config["roles"]["interrogate reviewers"] = ["Codex", "Kimi"]
        self.assertIn("has no family entry", " ".join(validate(config)))

    def test_rejects_single_seat_in_multi_seat_panels(self):
        for role in ("arena runners", "architect runners", "interrogate reviewers"):
            with self.subTest(role=role):
                config = valid_config()
                config["roles"][role] = ["Codex"]
                self.assertIn(role, " ".join(validate(config)))

    def test_accepts_single_cross_judge_choice(self):
        config = valid_config()
        config["roles"]["arena cross-judge pool"] = ["Codex"]
        self.assertEqual(validate(config), [])

    def test_rejects_missing_role(self):
        config = valid_config()
        del config["roles"]["bug-fix"]
        self.assertIn("missing roles", " ".join(validate(config)))


if __name__ == "__main__":
    unittest.main()
