import {IRCTC} from "irctc-api";

async function custom_function_name() {
    const irctc = new IRCTC({
        "userID": "AbhinavS215", // Secret User ID
        "password": "Abhinav@215", // Secret Password
    });
    const params = {
        "payment": "2abhinav15@okaxis", // Your NPCI UPI VPA ID
        "class": "2S", // class code such as 2A | 3A | SL | CC | 2S | FC | 1A | 3E | Any other valid class code
        "quota": "GN", // GN | TQ | PT | any other valid quota code
        "train": "12127", // 5 Digit Train Number - string
        "from": "TNA", // Station code
        "to": "PUNE", // Station code
        "date": "20250219", // YYYYMMDD
        "mobile": "8779784697", // 10 Digit Mobile Number
        "passengers": [ // Passengers List - Max 4 members for Tatkal and 6 for General Quota
            {
                "age": 20, // Age of Passenger - Integer
                "name": "Abhinav S", // Full Name of Passenger
                "gender": "M" // Gender of Passenger - M | F | T
            }
        ]
    };
    const response = await irctc.book(params);
    return response;
};
const ticket = await custom_function_name();
console.log(ticket);