import os
from typing import Optional
from app.core.config import settings

class GroqAIService:
    def __init__(self):
        self.api_key = settings.GROQ_API_KEY
        self.model = settings.GROQ_MODEL
        self._client = None

    def _get_client(self):
        if self._client is None:
            try:
                from groq import Groq
                self._client = Groq(api_key=self.api_key)
            except Exception:
                self._client = None
        return self._client

    async def generate_chat_response(self, user_message: str, user_role: str = "client") -> str:
        client = self._get_client()
        system_prompt = (
            "You are PSYNOVA AI, an empathetic, supportive digital mental health assistant. "
            "Your goal is to provide evidence-based emotional support, coping strategies, mindfulness tips, "
            "and active listening. ALWAYS maintain a compassionate, non-judgmental tone. "
            "IMPORTANT DISCLAIMER: Clearly communicate when needed that you are an AI assistant designed to "
            "support wellness, not a licensed medical professional or crisis intervention service."
        )

        if client and self.api_key and not self.api_key.startswith("gsk_dummy"):
            try:
                completion = client.chat.completions.create(
                    model=self.model,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_message}
                    ],
                    temperature=0.7,
                    max_tokens=500
                )
                return completion.choices[0].message.content
            except Exception as e:
                pass

        # Intelligent Fallback Response Engine
        lowered = user_message.lower()
        if "anxious" in lowered or "anxiety" in lowered or "panic" in lowered:
            return (
                "I hear how overwhelming things feel right now. When anxiety strikes, try the 4-7-8 breathing technique:\n"
                "1. Inhale quietly through your nose for 4 seconds.\n"
                "2. Hold your breath for 7 seconds.\n"
                "3. Exhale completely through your mouth for 8 seconds.\n\n"
                "Remember, thoughts are like clouds passing in the sky. You are safe, and your therapist is also available if you'd like to book a session."
            )
        elif "sad" in lowered or "depressed" in lowered or "lonely" in lowered:
            return (
                "Thank you for sharing your feelings with me. Feeling sad or lonely is a completely human experience. "
                "Be gentle with yourself today. Try doing one small comforting thing—like drinking warm water, going for a short walk, "
                "or writing down three things you are grateful for. I'm here to listen whenever you want to talk."
            )
        elif "sleep" in lowered or "insomnia" in lowered or "tired" in lowered:
            return (
                "Rest is crucial for mental well-being. To help ease into sleep:\n"
                "- Dim your ambient screen lighting 30 minutes before bed.\n"
                "- Try a progressive muscle relaxation exercise.\n"
                "- Focus on breathing deeply from your diaphragm."
            )
        else:
            return (
                f"Thank you for reaching out to PSYNOVA AI. I'm here to help you navigate your thoughts and feelings. "
                f"Whether you need coping strategies for stress, daily wellness motivation, or guidance on preparing for your next therapy session, "
                f"feel free to express whatever is on your mind."
            )

    async def summarize_journal(self, title: str, content: str) -> str:
        client = self._get_client()
        if client and self.api_key and not self.api_key.startswith("gsk_dummy"):
            try:
                prompt = f"Summarize the emotional themes and key takeaways of this personal journal entry briefly (2-3 sentences):\nTitle: {title}\nContent: {content}"
                completion = client.chat.completions.create(
                    model=self.model,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.5,
                    max_tokens=150
                )
                return completion.choices[0].message.content
            except Exception:
                pass
        
        return f"Summary: Reflection on '{title}'. Key emotional themes include self-awareness, mindfulness, and processing daily experiences."

    async def analyze_mood_trends(self, mood_scores: list[int]) -> str:
        if not mood_scores:
            return "No mood logs available yet. Keep checking in daily!"
        avg = sum(mood_scores) / len(mood_scores)
        if avg >= 4.0:
            return "Your emotional trend is exceptionally positive! You've shown consistent resilience and uplifted mood over recent days."
        elif avg >= 2.5:
            return "Your mood has been steady with balanced fluctuations. Practicing regular mindfulness & journaling will help maintain stability."
        else:
            return "We noticed your recent mood logs indicate heightened stress or emotional strain. Consider booking a session with a therapist or engaging in guided breathing."

groq_service = GroqAIService()
