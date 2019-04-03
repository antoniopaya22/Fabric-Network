
 package main

 import (
	 "bytes"
	 "encoding/json"
	 "fmt"
	 "strconv"
	 "time"
 
	 "github.com/hyperledger/fabric/core/chaincode/shim"
	 sc "github.com/hyperledger/fabric/protos/peer"
 )
 
 // Define la estructura del SmartContract
 type SmartContract struct {
 }
 
 // Define la estructura de Dato
 type Dato struct {
	 Temperature  string `json:"temperature"`
	 Hour		  string `json:"hour"`
	 GPS		  string `json:"gps"`
	 Device       string `json:"device"`
	 Node  		  string `json:"node"`
 }
 
 var id = 0;

 /*
  * El metodo Init se llama cuando el Smart Contract se instancia por la red blockchain
  */
 func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	 return shim.Success(nil)
 }
 
 /*
  * El metodo Invoke se llama como resultado de ejecutar el Smart Contract
  */
 func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	 function, args := APIstub.GetFunctionAndParameters()
 
	 if function == "queryDato" {
		 return s.queryDato(APIstub, args)
	 } else if function == "initLedger" {
		 return s.initLedger(APIstub)
	 } else if function == "addDato" {
		 return s.addDato(APIstub, args)
	 } else if function == "deleteDato" {
		 return s.deleteDato(APIstub, args)
	 } else if function == "queryAllDatos" {
		 return s.queryAllDatos(APIstub)
	 } else if function == "getDatoHistory" {
		 return s.getDatoHistory(APIstub, args)
	 } else if function == "updateDato" {
		 return s.updateDato(APIstub, args)
	 } else if function == "getLastNum" {
		return s.getLastNum(APIstub)
	 } else if function == "queryDatoCouchDB" {
		 return s.queryDatoCouchDB(APIstub, args)
	 }
 
	 return shim.Error("Nombre de funcion del SmartContract invalido o inexistente.")
 }
 
 func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	 datos := []Dato{
		 Dato{
			 Temperature: "39",
			 Hour: "x",
			 GPS: "x",
			 Device: "x",
			 Node: "x"},
	 }
	datoAsBytes, _ := json.Marshal(datos[0])
	APIstub.PutState("ID_PRUEBA_"+strconv.Itoa(0), datoAsBytes)
	fmt.Println("Added", datos[0])
 
	 return shim.Success(nil)
 }
 
 func (s *SmartContract) getDatoHistory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
	 if len(args) != 1 {
		 return shim.Error("Numero incorrecto de argumentos, se esperaba 1")
	 }
 
	 datoName := args[0]
 
	 resultsIterator, err := APIstub.GetHistoryForKey(datoName)
	 if err != nil {
		 return shim.Error(err.Error())
	 }
	 defer resultsIterator.Close()
 
	 var buffer bytes.Buffer
	 buffer.WriteString("[")
 
	 bArrayMemberAlreadyWritten := false
	 for resultsIterator.HasNext() {
		 response, err := resultsIterator.Next()
		 if err != nil {
			 return shim.Error(err.Error())
		 }

		 if bArrayMemberAlreadyWritten == true {
			 buffer.WriteString(",")
		 }
		 buffer.WriteString("{\"TxId\":")
		 buffer.WriteString("\"")
		 buffer.WriteString(response.TxId)
		 buffer.WriteString("\"")
 
		 buffer.WriteString(", \"Value\":")

		 if response.IsDelete {
			 buffer.WriteString("null")
		 } else {
			 buffer.WriteString(string(response.Value))
		 }
 
		 buffer.WriteString(", \"Timestamp\":")
		 buffer.WriteString("\"")
		 buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		 buffer.WriteString("\"")
 
		 buffer.WriteString(", \"IsDelete\":")
		 buffer.WriteString("\"")
		 buffer.WriteString(strconv.FormatBool(response.IsDelete))
		 buffer.WriteString("\"")
 
		 buffer.WriteString("}")
		 bArrayMemberAlreadyWritten = true
	 }
	 buffer.WriteString("]")
 
	 fmt.Printf("- getHistoryForDato returning:\n%s\n", buffer.String())
 
	 return shim.Success(buffer.Bytes())
 }
 
 func (s *SmartContract) queryDato(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
	 if len(args) != 1 {
		 return shim.Error("Numero incorrecto de argumentos, se esperaba 1")
	 }
 
	 datoAsBytes, _ := APIstub.GetState(args[0])
	 return shim.Success(datoAsBytes)
 }
 
 func (s *SmartContract) addDato(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
	 if len(args) != 6 {
		 return shim.Error("Numero incorrecto de argumentos, se esperaban 6 ")
	 }

	 id = id + 1
 
	 var dato = Dato{Temperature: args[1], Hour: args[2], GPS: args[3], Device: args[4], Node: args[5]}
 
	 datoAsBytes, _ := json.Marshal(dato)
	 APIstub.PutState(args[0], datoAsBytes)
	 return shim.Success(nil)
 }

 func (s *SmartContract) updateDato(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
	if len(args) != 6 {
		return shim.Error("Numero incorrecto de argumentos, se esperaban 6 ")
	}

	var dato = Dato{Temperature: args[1], Hour: args[2], GPS: args[3], Device: args[4], Node: args[5]}

	datoAsBytes, _ := json.Marshal(dato)
	APIstub.PutState(args[0], datoAsBytes)
	return shim.Success(nil)
}
 
 func (s *SmartContract) deleteDato(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
 
	 if len(args) != 2 {
		 return shim.Error("Numero incorrecto de argumentos, se esperaban 2")
	 }
 
	 APIstub.DelState(args[0])
	 return shim.Success(nil)
 }
 
 func (s *SmartContract) queryAllDatos(APIstub shim.ChaincodeStubInterface) sc.Response {
 
	 startKey := ""
	 endKey := ""
 
	 fmt.Println("Llamada a queryAllDatos")
 
	 resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	 if err != nil {
		 return shim.Error(err.Error())
	 }
	 defer resultsIterator.Close()
 
	 // buffer es un array JSON con los resultados de la consulta
	 var buffer bytes.Buffer
	 buffer.WriteString("[")
 
	 bArrayMemberAlreadyWritten := false
	 for resultsIterator.HasNext() {
		 queryResponse, err := resultsIterator.Next()
		 if err != nil {
			 return shim.Error(err.Error())
		 }
		 if bArrayMemberAlreadyWritten == true {
			 buffer.WriteString(",")
		 }
		 buffer.WriteString("{\"Key\":")
		 buffer.WriteString("\"")
		 buffer.WriteString(queryResponse.Key)
		 buffer.WriteString("\"")
 
		 buffer.WriteString(", \"Record\":")
		 // Guardarlo como un objeto JSON
		 buffer.WriteString(string(queryResponse.Value))
		 buffer.WriteString("}")
		 bArrayMemberAlreadyWritten = true
	 }
	 buffer.WriteString("]")
 
	 fmt.Printf("- queryAllDatos:\n%s\n", buffer.String())
 
	 return shim.Success(buffer.Bytes())
 }

 func (s *SmartContract) getLastNum(APIstub shim.ChaincodeStubInterface) sc.Response {
	var buffer bytes.Buffer
	buffer.WriteString("{\"Num\":")
	buffer.WriteString("\"")
	buffer.WriteString(strconv.Itoa(id))
	buffer.WriteString("\"")
	buffer.WriteString("}")

	fmt.Printf("- getLastNum:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) queryDatoCouchDB(stub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 1 {
		return shim.Error("Numero incorrecto de argumentos, se esperaba 1")
	}
	queryString := args[0]
	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}
 
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())
	return buffer.Bytes(), nil
}

func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}


// Esta funcion solo es relevante para pruebas unitarias.
func main() {
	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error al crear el Smart Contract: %s", err)
	}
 }
 