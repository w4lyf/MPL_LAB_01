
import { IRCTC } from "irctc-api";
import fs from "fs";

async function bookTicket() {
    const irctc = new IRCTC({
        userID: "AbhinavS215",
        password: "Abhinav@215"
    });

    const params = {
        train: "11007",
        from: "CSMT",
        to: "PUNE",
        class: "2A",
        quota: "GN",
        date: "20250326",
        mobile: "8779784697",
        "payment": "2abhinav15@okaxis", 
        passengers: [{ age: 20, name: "Abhinav S", gender: "M" }]
    };

    const response = await irctc.book(params);
    console.log(JSON.stringify(response)); // Ensure response is logged as JSON
}
bookTicket();
