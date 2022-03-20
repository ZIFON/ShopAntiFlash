#include <sourcemod>
#include <shop>
#include <blindhook>
#include <sdktools_hooks>



public Plugin myinfo =
{
    name =  "[Shop]AntiFlash" ,
    author =  "ZIFON & FIVE" ,
    description =  "https://github.com/ZIFON" ,
    version =  "1.0" ,
    url =  "https://github.com/ZIFON"
};

bool g_bclients[MAXPLAYERS+1];
CategoryId gcategory_id;
ItemId g_iID;

public void OnPluginStart()
{
    if(Shop_IsStarted()) Shop_Started();
    AutoExecConfig(true, "shop_antiflash");
}

public void Shop_Started()
{
    gcategory_id = Shop_RegisterCategory("ability", "Способности", "");
    if (Shop_StartItem(gcategory_id, "shop_antiflash"))
    {
            ConVar CVARB, CVARS, CVART;

	        (CVARB = CreateConVar("sm_shop_antiflast_price", "450", "Цена покупки.", _, true, 0.0)).AddChangeHook(ChangeCvar_Buy);
	        (CVARS = CreateConVar("sm_shop_antiflast_sell_price", "200", "Цена продажи.", _, true, 0.0)).AddChangeHook(ChangeCvar_Sell);
	        (CVART = CreateConVar("sm_shop_antiflast_time", "86400", "Время действия покупки в секундах.", _, true, 0.0)).AddChangeHook(ChangeCvar_Time);
        
            Shop_SetInfo("AntiFlash", "Анти-флеш", CVARB.IntValue, CVARS.IntValue, Item_Togglable, CVART.IntValue);
            Shop_SetCallbacks(OnItemRegistered, OnEquipItem);
            Shop_EndItem();
    }
}

public Action CS_OnBlindPlayer(int iClient, int iAttacker, int iInflictor)
{
    if (g_bclients[iClient])
        return Plugin_Stop;

    return Plugin_Continue;
} 


public void OnClientDisconnect(int iClient)
{
    g_bclients[iClient] = false;
}

public void ChangeCvar_Buy(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemPrice(g_iID, convar.IntValue);
}

public void ChangeCvar_Sell(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemSellPrice(g_iID, convar.IntValue);
}
public void ChangeCvar_Time(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemValue(g_iID, convar.IntValue);
}
public void OnItemRegistered(CategoryId category_id, const char[] sCategory, const char[] sItem, ItemId item_id)
{
	g_iID = item_id;
}
public ShopAction OnEquipItem(int iClient, CategoryId category_id, const char[] sCategory, ItemId item_id, const char[] sItem, bool isOn, bool elapsed)
{
	if (isOn || elapsed)
	{
		g_bclients[iClient] = false;
		return Shop_UseOff;
	}

	g_bclients[iClient] = true;

	return Shop_UseOn;
}
