LoadPizzaMap() {

    // npc
    CreateActor(155, 2098.50, -1801.50, 13.38, 90);

    // getjob
    Create3DTextLabel("[Pengantar Pizza]\n{fff000}/getjob", -1, 2097.5, -1801.50, 13.4, 3, -1);
    CreatePickup(1239, 1, 2097.5, -1801.50, 13.0, -1);

    // ambil pizza
    Create3DTextLabel("{fff000}/getpizza", -1, 2095.08, -1796.74, 13.4, 2, -1);
    CreatePickup(1582, 1, 2095.08, -1796.74, 13.0, -1);

}
