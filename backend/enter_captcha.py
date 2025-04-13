import sys
import time
import pyautogui

def enter_captcha(captcha_text):
    time.sleep(2)  # ✅ Wait for terminal focus
    print(f"Typing CAPTCHA: {captcha_text}")
    pyautogui.typewrite(captcha_text, interval=0.05)  # ✅ Type CAPTCHA
    pyautogui.press('enter')  # ✅ Press Enter

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Error: No CAPTCHA input received")
        sys.exit(1)

    captcha_input = sys.argv[1]
    enter_captcha(captcha_input)
