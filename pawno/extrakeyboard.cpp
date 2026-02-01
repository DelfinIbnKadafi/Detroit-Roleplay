#include "main.h"
#include "gui/gui.h"
#include "game/game.h"
#include "net/netgame.h"
#include "settings.h"
#include "dialog.h"
#include "spawnscreen.h"
#include "extrakeyboard.h"
#include "scoreboard.h"

extern CGUI *pGUI;
extern CGame *pGame;
extern CNetGame *pNetGame;
extern CSettings *pSettings;
extern CScoreBoard *pScoreBoard;
extern CDialogWindow *pDialogWindow;
extern CSpawnScreen *pSpawnScreen;

CExtraKeyBoard::CExtraKeyBoard() 
{
	m_bIsActive = false;
	m_bIsExtraShow = false;
	Log("Extrakeyboard initialized.");
}

CExtraKeyBoard::~CExtraKeyBoard() { }

void CExtraKeyBoard::Show(bool bShow) 
{
	m_bIsActive = bShow;
}

void CExtraKeyBoard::Render() 
{
	if(!m_bIsActive || pSpawnScreen->m_bEnabled || pDialogWindow->m_bIsActive)
		return;
	
	ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(4.5f, 4.5f));
	ImGui::PushStyleVar(ImGuiStyleVar_ButtonTextAlign, ImVec2(0.5f, 0.5f));

	CPlayerPed *pPlayerPed = pGame->FindPlayerPed();
	if(pPlayerPed) 
	{
		ImGuiIO &io = ImGui::GetIO();

		ImGui::Begin(" ", nullptr, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings);

		m_fButWidth = ImGui::CalcTextSize("ASDFG").x;
		m_fButHeight = ImGui::CalcTextSize("ASDF").x;
			
		if(ImGui::Button(m_bIsExtraShow ? "<<<<" : ">>>>", ImVec2(m_fButWidth, m_fButHeight)))
		{
			if(!pScoreBoard->m_bToggle)
				m_bIsExtraShow = !m_bIsExtraShow;
		}
		if(m_bIsExtraShow) 
		{
	        ImGui::SameLine(0, 4);
			if(ImGui::Button("F", ImVec2(m_fButWidth, m_fButHeight)))
				LocalPlayerKeys.bKeys[ePadKeys::KEY_SECONDARY_ATTACK] = true;
			
			ImGui::SameLine(0, 4);
			if(ImGui::Button("Y", ImVec2(m_fButWidth, m_fButHeight)))
				LocalPlayerKeys.bKeys[ePadKeys::KEY_YES] = true;
			
			ImGui::SameLine(0, 4);
			if(ImGui::Button("N", ImVec2(m_fButWidth, m_fButHeight)))
				LocalPlayerKeys.bKeys[ePadKeys::KEY_NO] = true;

			ImGui::SameLine(0, 4);
			if(ImGui::Button("H", ImVec2(m_fButWidth, m_fButHeight)))
				LocalPlayerKeys.bKeys[ePadKeys::KEY_CTRL_BACK] = true;
				
				}
			ImGui::SameLine(0, 4);
			if(pPlayerPed->IsInVehicle()) 
			{
				if(ImGui::Button("ALT", ImVec2(m_fButWidth, m_fButHeight)))
					LocalPlayerKeys.bKeys[ePadKeys::KEY_FIRE] = true;

				if(!pPlayerPed->IsAPassenger()) 
				{
					ImGui::SameLine(0, 4);
					if(ImGui::Button("2", ImVec2(m_fButWidth, m_fButHeight)))
						LocalPlayerKeys.bKeys[ePadKeys::KEY_SUBMISSION] = true;
				}
			} 
			else 
			{
				if(ImGui::Button("ALT", ImVec2(m_fButWidth, m_fButHeight)))
					LocalPlayerKeys.bKeys[ePadKeys::KEY_WALK] = true;
			}
		{
		ImGui::SameLine(0, 5);
			if(ImGui::Button("GUN", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rpgun");
            		
				
		    ImGui::SameLine(0, 5);
			if(ImGui::Button("SHOT", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rpshoot");
		
		ImGui::SameLine(0, 5);
			if(ImGui::Button("SAVEG", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rpsavegun");
            }
			{	
		    ImGui::SameLine(0, 5);
			if(ImGui::Button("HELM", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rphelm");
             	
			ImGui::SameLine(0, 5);
			if(ImGui::Button("PLANT", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rpplant");
            
				
		    ImGui::SameLine(0, 5);
			if(ImGui::Button("HARVEST", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rpharvest");
             
             		ImGui::SameLine(0, 5);
			if(ImGui::Button("TIE", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rptie");
            
				
		    ImGui::SameLine(0, 5);
			if(ImGui::Button("untie", ImVec2(m_fButWidth, m_fButHeight)))
            
               pNetGame->SendChatCommand("/rpuntie");
		}
		
		
		CVehiclePool *pVehiclePool = pNetGame->GetVehiclePool();
		if(pVehiclePool) 
		{
			uint16_t sNearestVehicleID = pVehiclePool->FindNearestToLocalPlayerPed();
			CVehicle *pVehicle = pVehiclePool->GetAt(sNearestVehicleID);
			if(pVehicle)
			{
				if(pVehicle->GetDistanceFromLocalPlayerPed() < 4.0f) 
				{
					CPlayerPool *pPlayerPool = pNetGame->GetPlayerPool();
					if(pPlayerPool) 
					{
						CLocalPlayer *pLocalPlayer = pPlayerPool->GetLocalPlayer();
						if(pLocalPlayer)
						{
							if(!pLocalPlayer->IsSpectating()) 
							{
								if(!pPlayerPed->IsInVehicle())
								{
									ImGui::SameLine(0, 4);
									if(ImGui::Button("G", ImVec2(m_fButWidth, m_fButHeight)))
									{
										pPlayerPed->EnterVehicle(pVehicle->m_dwGTAId, true);
										pLocalPlayer->SendEnterVehicleNotification(sNearestVehicleID, true);
									}
								}
							}
						}
					}
				}
			}
		}
		
		ImGui::SetWindowSize(ImVec2(-1, -1));
		ImVec2 size = ImGui::GetWindowSize();
		ImGui::SetWindowPos(ImVec2(pGUI->ScaleX(10), pGUI->ScaleY(345)));
		ImGui::End();
		
		ImGui::PopStyleVar();
	}
	return;
}
