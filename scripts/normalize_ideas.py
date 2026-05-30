#!/usr/bin/env python3
"""
规范化 frontend_creative_ideas.yaml 文件
为所有创意添加标准化字段：
- requires_permission
- interruption_level
- fallback_interaction
- privacy_risk
- privacy_note
"""

import re

def normalize_yaml():
    input_file = 'docs/frontend_creative_ideas.yaml'
    output_file = 'docs/frontend_creative_ideas_normalized.yaml'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 定义每个创意的标准化规则
    normalizations = {
        'raise_phone_high_power_up': {
            'requires_permission': '[]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"长按按钮蓄力"',
            'data_needed_fix': {
                'old': '"phone height"',
                'new': '"orientation angle"\n      - "charge progress"'
            },
            'acceptance_fix': {
                'old': '高度检测准确',
                'new': '姿态检测稳定'
            }
        },
        'blow_mic_magic_effect': {
            'requires_permission': '["microphone"]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"长按按钮施法"',
            'privacy_risk': '"medium"',
            'privacy_note': '"仅本地检测音量，不上传音频数据"'
        },
        'clap_rhythm_cheer': {
            'requires_permission': '["microphone"]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"点击按钮应援"',
            'privacy_risk': '"medium"',
            'privacy_note': '"仅本地检测节奏，不上传音频数据"'
        },
        'face_expression_emotion_sync': {
            'requires_permission': '["camera"]',
            'interruption_level': '"high"',
            'privacy_risk': '"high"',
            'privacy_note': '"所有处理在本地完成，不上传图像数据"'
        },
        'tilt_phone_peek_scene': {
            'requires_permission': '[]',
            'interruption_level': '"low"',
            'fallback_interaction': '"滑动手势查看隐藏内容"'
        },
        'cover_screen_hide_from_villain': {
            'requires_permission': '[]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"点击按钮躲避"'
        },
        'draw_gesture_cast_spell': {
            'requires_permission': '[]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"点击按钮施法"'
        },
        'multi_finger_tap_combo': {
            'requires_permission': '[]',
            'interruption_level': '"low"'
        },
        'shake_phone_to_cheer': {
            'requires_permission': '[]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"点击按钮加油"'
        },
        'voice_cheer_shout': {
            'requires_permission': '["microphone"]',
            'interruption_level': '"medium"',
            'fallback_interaction': '"点击按钮喊话"',
            'privacy_risk': '"medium"',
            'privacy_note': '"仅本地检测音量，不上传音频数据"'
        }
    }

    # 应用规范化
    for idea_id, rules in normalizations.items():
        # 查找该创意的位置
        pattern = rf'(- id: "{idea_id}".*?)((?=\n  - id:)|(?=\n# =====)|$)'

        def replace_idea(match):
            idea_block = match.group(1)

            # 添加 requires_permission（如果不存在）
            if 'requires_permission:' not in idea_block and 'requires_permission' in rules:
                # 在 effort 后面插入
                idea_block = re.sub(
                    r'(effort: "[^"]*")',
                    rf'\1\n    requires_permission: {rules["requires_permission"]}',
                    idea_block
                )

            # 添加 interruption_level
            if 'interruption_level:' not in idea_block and 'interruption_level' in rules:
                idea_block = re.sub(
                    r'(requires_permission: \[.*?\])',
                    rf'\1\n    interruption_level: {rules["interruption_level"]}',
                    idea_block
                )

            # 添加 fallback_interaction
            if 'fallback_interaction' in rules:
                if 'fallback_interaction:' not in idea_block:
                    idea_block = re.sub(
                        r'(interruption_level: "[^"]*")',
                        rf'\1\n    fallback_interaction: {rules["fallback_interaction"]}',
                        idea_block
                    )

            # 添加 privacy_risk 和 privacy_note
            if 'privacy_risk' in rules:
                if 'privacy_risk:' not in idea_block:
                    idea_block = re.sub(
                        r'(fallback_interaction: "[^"]*")',
                        rf'\1\n    privacy_risk: {rules["privacy_risk"]}',
                        idea_block
                    )
                    if 'privacy_note' in rules:
                        idea_block = re.sub(
                            r'(privacy_risk: "[^"]*")',
                            rf'\1\n    privacy_note: {rules["privacy_note"]}',
                            idea_block
                        )

            # 修复 data_needed
            if 'data_needed_fix' in rules:
                fix = rules['data_needed_fix']
                idea_block = idea_block.replace(fix['old'], fix['new'])

            # 修复 acceptance_signals
            if 'acceptance_fix' in rules:
                fix = rules['acceptance_fix']
                idea_block = idea_block.replace(fix['old'], fix['new'])

            return idea_block

        content = re.sub(pattern, replace_idea, content, flags=re.DOTALL)

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✅ 规范化完成，输出到: {output_file}")
    print("请检查后替换原文件")

if __name__ == '__main__':
    normalize_yaml()
