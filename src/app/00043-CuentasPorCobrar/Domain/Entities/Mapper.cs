using Data.Types;
using ExcelDataReader;
using NDbfReader;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public static class Mapper
    {
        public static DataMatriculaType MatriculaReader_To_DataMatriculaType(Reader reader)
        {
            DataMatriculaType dataMatriculaType = new DataMatriculaType()
            {
                C_CodRC = reader.GetString("COD_RC"),
                C_CodAlu = reader.GetString("COD_ALU"),
                I_Anio = reader.GetInt32("ANO"),
                C_Periodo = reader.GetString("P"),
                C_EstMat = reader.GetString("EST_MAT"),
                C_Ciclo = reader.GetString("NIVEL"),
                B_Ingresante = reader.GetBoolean("ES_INGRESA"),
                I_CreditosDesaprob = reader.GetInt32("CRED_DESAP")
            };

            return dataMatriculaType;
        }

        public static DataMatriculaType MatriculaReader_To_DataMatriculaType(IExcelDataReader reader)
        {
            string stringValue; int intValue;

            DataMatriculaType dataMatriculaType = new DataMatriculaType()
            {
                C_CodRC = reader.GetValue(0)?.ToString(),
                C_CodAlu = reader.GetValue(1)?.ToString(),
                C_Periodo = reader.GetValue(3)?.ToString(),
                C_EstMat = reader.GetValue(4)?.ToString(),
                C_Ciclo = reader.GetValue(5)?.ToString()
            };
            
            if (reader.GetValue(2) != null)
            {
                stringValue = reader.GetValue(2).ToString();

                if (int.TryParse(stringValue, out intValue))
                    dataMatriculaType.I_Anio = intValue;
            }

            if (reader.GetValue(6) != null)
            {
                stringValue = reader.GetValue(6).ToString();

                if (stringValue.Equals("T", StringComparison.OrdinalIgnoreCase))
                    dataMatriculaType.B_Ingresante = true;

                if (stringValue.Equals("F", StringComparison.OrdinalIgnoreCase))
                    dataMatriculaType.B_Ingresante = false;
            }

            if (reader.GetValue(7) != null)
            {
                stringValue = reader.GetValue(7).ToString();

                if (stringValue.Trim() == "")
                    dataMatriculaType.I_CreditosDesaprob = 0;
                else if (int.TryParse(stringValue, out intValue))
                    dataMatriculaType.I_CreditosDesaprob = intValue;
            }
            else
            {
                dataMatriculaType.I_CreditosDesaprob = 0;
            }
            
            return dataMatriculaType;
        }

        public static DataMatriculaResult DataMatriculaType_To_DataMatriculaResult(DataMatriculaType dataMatricula, bool B_Success, string T_Message)
        {
            var dataMatriculaResult = new DataMatriculaResult()
            {
                C_CodRC = dataMatricula.C_CodRC,
                C_CodAlu = dataMatricula.C_CodAlu,
                I_Anio = dataMatricula.I_Anio,
                C_Periodo = dataMatricula.C_Periodo,
                C_EstMat = dataMatricula.C_EstMat,
                C_Ciclo = dataMatricula.C_Ciclo,
                B_Ingresante = dataMatricula.B_Ingresante,
                I_CreditosDesaprob = dataMatricula.I_CreditosDesaprob,
                B_Success = B_Success,
                T_Message = T_Message
            };

            return dataMatriculaResult;
        }

        public static DataTable DataMatriculaTypeList_To_DataTable(List<DataMatriculaType> dataMatriculas)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_CodRC");
            dataTable.Columns.Add("C_CodAlu");
            dataTable.Columns.Add("I_Anio");
            dataTable.Columns.Add("C_Periodo");
            dataTable.Columns.Add("C_EstMat");
            dataTable.Columns.Add("C_Ciclo");
            dataTable.Columns.Add("B_Ingresante");
            dataTable.Columns.Add("I_CredDesaprob");

            dataMatriculas.ForEach(x => dataTable.Rows.Add(
                x.C_CodRC,
                x.C_CodAlu,
                x.I_Anio,
                x.C_Periodo,
                x.C_EstMat,
                x.C_Ciclo,
                x.B_Ingresante,
                x.I_CreditosDesaprob
            ));

            return dataTable;
        }
    }
}
