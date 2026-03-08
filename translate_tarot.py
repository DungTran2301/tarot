import json
import time
from deep_translator import GoogleTranslator

def translate_batch(texts):
    if not texts:
        return []
    
    # Lọc ra các chuỗi hợp lệ
    valid_texts = [str(t).strip() for t in texts if t and str(t).strip()]
    if not valid_texts:
        return texts
        
    try:
        # Nhóm chuỗi bằng ký tự phân tách đặc biệt
        separator = " \n~|~\n "
        joined_text = separator.join(valid_texts)
        translated_joined = GoogleTranslator(source='en', target='vi').translate(joined_text)
        time.sleep(0.3)
        
        # Tách lại
        translated_texts = [t.strip() for t in translated_joined.split("~|~")]
        
        # Điền lại vào list gốc, giữ nguyên các vị trí rỗng
        result = []
        valid_idx = 0
        for t in texts:
            if t and str(t).strip():
                if valid_idx < len(translated_texts):
                    result.append(translated_texts[valid_idx])
                    valid_idx += 1
                else:
                    result.append(t) # Fallback if split fails
            else:
                result.append(t)
        return result
    except Exception as e:
        print(f"Lỗi khi dịch batch: {e}")
        return texts

def main():
    input_file = 'assets/data/tarot-images.json'
    output_file = 'assets/data/tarot-images-vn.json'

    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    cards = data.get('cards', [])
    total_cards = len(cards)
    
    print(f"Bắt đầu dịch {total_cards} lá bài (Batch Model)...")

    for i, card in enumerate(cards):
        print(f"[{i+1}/{total_cards}] Đang thu thập văn bản cho: {card['name']}...")
        
        # Thu thập toàn bộ chuỗi vào 1 mảng
        strings_to_translate = []
        
        strings_to_translate.append(card['name'])
        
        kw_start = len(strings_to_translate)
        if 'keywords' in card:
            strings_to_translate.extend(card['keywords'])
        kw_end = len(strings_to_translate)
            
        ft_start = len(strings_to_translate)
        if 'fortune_telling' in card:
            strings_to_translate.extend(card['fortune_telling'])
        ft_end = len(strings_to_translate)
            
        ml_start = len(strings_to_translate)
        ms_start = len(strings_to_translate)
        ms_end = len(strings_to_translate)
        ml_end = len(strings_to_translate)
        
        if 'meanings' in card:
            if 'light' in card['meanings']:
                ml_start = len(strings_to_translate)
                strings_to_translate.extend(card['meanings']['light'])
                ml_end = len(strings_to_translate)
            if 'shadow' in card['meanings']:
                ms_start = len(strings_to_translate)
                strings_to_translate.extend(card['meanings']['shadow'])
                ms_end = len(strings_to_translate)
                
        qa_start = len(strings_to_translate)
        if 'Questions to Ask' in card:
            strings_to_translate.extend(card['Questions to Ask'])
        qa_end = len(strings_to_translate)

        # Dịch 1 lần cho toàn bộ lá bài
        translated_strings = translate_batch(strings_to_translate)

        # Gán ngược lại vào object nếu số lượng khớp
        if len(translated_strings) == len(strings_to_translate):
            card['nameVn'] = translated_strings[0]
            if 'keywords' in card:
                card['keywords'] = translated_strings[kw_start:kw_end]
            if 'fortune_telling' in card:
                card['fortune_telling'] = translated_strings[ft_start:ft_end]
            if 'meanings' in card:
                if 'light' in card['meanings']:
                    card['meanings']['light'] = translated_strings[ml_start:ml_end]
                if 'shadow' in card['meanings']:
                    card['meanings']['shadow'] = translated_strings[ms_start:ms_end]
            if 'Questions to Ask' in card:
                card['Questions to Ask'] = translated_strings[qa_start:qa_end]
        else:
            print(f"X Cảnh báo: Lỗi gãy chunk phân tách ở lá {card['name']}. Sẽ dùng tiếng Anh nguyên gốc.")
            card['nameVn'] = card['name']

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("Dịch hoàn tất! Đã lưu vào", output_file)

if __name__ == '__main__':
    main()
