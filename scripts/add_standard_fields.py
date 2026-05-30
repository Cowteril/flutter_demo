#!/usr/bin/env python3
"""
为所有创意添加标准化字段
"""

import re

# 定义每个创意的标准化配置
IDEA_CONFIGS = {
    'immersive_vertical_feed': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'double_tap_heart_burst': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'highlight_effect_trigger_bar': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'reaction_particle_presets': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'branch_choice_moment': {
        'requires_permission': '[]',
        'interruption_level': '"medium"',
    },
    'throw_at_disliked_character': {
        'requires_permission': '[]',
        'interruption_level': '"medium"',
    },
    'character_tracking_targeting': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'impact_combo_and_heat_meter': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'real_time_audience_heatmap': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'shake_phone_to_cheer': {
        'requires_permission': '[]',
        'interruption_level': '"medium"',
        'fallback_interaction': '"点击按钮加油"',
    },
    'voice_cheer_shout': {
        'requires_permission': '["microphone"]',
        'interruption_level': '"medium"',
        'fallback_interaction': '"点击按钮喊话"',
        'privacy_risk': '"medium"',
        'privacy_note': '"仅本地检测音量，不上传音频数据"',
    },
    'plot_prediction_quiz': {
        'requires_permission': '[]',
        'interruption_level': '"high"',
    },
    'character_favorability_meter': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'screenshot_with_sticker_share': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'hidden_easter_egg_hunt': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'multi_angle_camera_switch': {
        'requires_permission': '[]',
        'interruption_level': '"medium"',
    },
    'ai_generated_sequel_prompt': {
        'requires_permission': '[]',
        'interruption_level': '"high"',
    },
    'emotion_sync_ambient_light': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'live_watch_party_room': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'achievement_badge_collection': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'tilt_phone_peek_scene': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
        'fallback_interaction': '"滑动手势查看隐藏内容"',
    },
    'blow_mic_magic_effect': {
        'requires_permission': '["microphone"]',
        'interruption_level': '"medium"',
        'fallback_interaction': '"长按按钮施法"',
        'privacy_risk': '"medium"',
        'privacy_note': '"仅本地检测音量，不上传音频数据"',
    },
    'cover_screen_hide_from_villain': {
        'requires_permission': '[]',
        'interruption_level': '"medium"',
        'fallback_interaction': '"点击按钮躲避"',
        'experimental': 'true',
    },
    'draw_gesture_cast_spell': {
        'requires_permission': '[]',
        'interruption_level': '"medium"',
        'fallback_interaction': '"点击按钮施法"',
    },
    'clap_rhythm_cheer': {
        'requires_permission': '["microphone"]',
        'interruption_level': '"medium"',
        'fallback_interaction': '"点击按钮应援"',
        'privacy_risk': '"medium"',
        'privacy_note': '"仅本地检测节奏，不上传音频数据"',
    },
    'multi_finger_tap_combo': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
    'face_expression_emotion_sync': {
        'requires_permission': '["camera"]',
        'interruption_level': '"high"',
        'privacy_risk': '"high"',
        'privacy_note': '"所有处理在本地完成，不上传图像数据"',
    },
    'daily_drama_challenge': {
        'requires_permission': '[]',
        'interruption_level': '"low"',
    },
}

def add_fields_after_effort(content, idea_id, config):
    """在 effort 字段后添加标准化字段"""

    # 查找该创意块
    pattern = rf'(  - id: "{idea_id}".*?effort: "[^"]*")'

    def replacer(match):
        block = match.group(1)

        # 构建要添加的字段
        fields_to_add = []

        if 'requires_permission' in config:
            fields_to_add.append(f"    requires_permission: {config['requires_permission']}")

        if 'interruption_level' in config:
            fields_to_add.append(f"    interruption_level: {config['interruption_level']}")

        if 'fallback_interaction' in config:
            fields_to_add.append(f"    fallback_interaction: {config['fallback_interaction']}")

        if 'privacy_risk' in config:
            fields_to_add.append(f"    privacy_risk: {config['privacy_risk']}")

        if 'privacy_note' in config:
            fields_to_add.append(f"    privacy_note: {config['privacy_note']}")

        if 'experimental' in config:
            fields_to_add.append(f"    experimental: {config['experimental']}")

        if fields_to_add:
            return block + '\n' + '\n'.join(fields_to_add)
        return block

    return re.sub(pattern, replacer, content, flags=re.DOTALL)

def main():
    input_file = 'docs/frontend_creative_ideas.yaml'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 为每个创意添加字段
    for idea_id, config in IDEA_CONFIGS.items():
        # 检查是否已经有这些字段
        idea_pattern = rf'- id: "{idea_id}".*?(?=\n  - id:|\Z)'
        match = re.search(idea_pattern, content, re.DOTALL)

        if match:
            idea_block = match.group(0)

            # 只有当字段不存在时才添加
            if 'requires_permission:' not in idea_block:
                content = add_fields_after_effort(content, idea_id, config)
                print(f"[OK] Added fields for {idea_id}")
            else:
                print(f"[SKIP] {idea_id} already has fields")
        else:
            print(f"[WARN] Not found: {idea_id}")

    # 写回文件
    with open(input_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print("\n[DONE] All ideas normalized")

if __name__ == '__main__':
    main()
