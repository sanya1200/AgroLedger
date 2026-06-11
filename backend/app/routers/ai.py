import logging
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
import google.generativeai as genai
from app.core.config import settings
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()
logger = logging.getLogger(__name__)

class AiConsultRequest(BaseModel):
    query: str

class AiConsultResponse(BaseModel):
    answer: str

# Системный промпт для ограничения контекста
SYSTEM_PROMPT = """
Ты — профессиональный ИИ-Ветеринар и консультант по животноводству для фермеров (AgroLedger).
Отвечай только на вопросы, связанные с сельским хозяйством, ветеринарией, разведением скота, кормлением и болезнями животных.
Если вопрос не связан с сельским хозяйством, вежливо откажись отвечать.
Всегда добавляй краткий дисклеймер в конце ответа: "Мои советы носят справочный характер, проконсультируйтесь с реальным ветеринаром для точного диагноза."
"""

@router.post("/consult", response_model=AiConsultResponse)
async def consult_ai(request: AiConsultRequest, current_user: User = Depends(get_current_user)):
    if not settings.GEMINI_API_KEY:
        logger.warning("GEMINI_API_KEY is not set. Returning mock response.")
        return AiConsultResponse(
            answer="В данный момент ИИ-консультант недоступен (не настроен API ключ Gemini). "
                   "Мои советы носят справочный характер, проконсультируйтесь с реальным ветеринаром для точного диагноза."
        )

    try:
        genai.configure(api_key=settings.GEMINI_API_KEY)
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction=SYSTEM_PROMPT
        )
        response = model.generate_content(request.query)
        return AiConsultResponse(answer=response.text)
    except Exception as e:
        logger.error(f"Error calling Gemini API: {e}")
        raise HTTPException(status_code=503, detail="Ошибка при обращении к ИИ-сервису")
