using Data.Types;
using Data.Views;
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
                I_CredDesaprob = reader.GetInt32("CRED_DESAP")
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
                    dataMatriculaType.I_CredDesaprob = 0;
                else if (int.TryParse(stringValue, out intValue))
                    dataMatriculaType.I_CredDesaprob = intValue;
            }
            else
            {
                dataMatriculaType.I_CredDesaprob = 0;
            }

            if (reader.FieldCount > 8)
            {
                if (reader.GetValue(9) != null)
                {
                    dataMatriculaType.B_ActObl = reader.GetValue(9).ToString().Equals("T", StringComparison.OrdinalIgnoreCase);
                }
            }

            return dataMatriculaType;
        }

        public static DataMatriculaObs DataMatriculaType_To_DataMatriculaObs(DataMatriculaType dataMatricula, bool B_Success, string T_Message)
        {
            var dataMatriculaObs = new DataMatriculaObs()
            {
                C_CodRC = dataMatricula.C_CodRC,
                C_CodAlu = dataMatricula.C_CodAlu,
                I_Anio = dataMatricula.I_Anio,
                C_Periodo = dataMatricula.C_Periodo,
                C_EstMat = dataMatricula.C_EstMat,
                C_Ciclo = dataMatricula.C_Ciclo,
                B_Ingresante = dataMatricula.B_Ingresante,
                I_CredDesaprob = dataMatricula.I_CredDesaprob,
                B_Success = B_Success,
                T_Message = T_Message
            };

            return dataMatriculaObs;
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
            dataTable.Columns.Add("B_ActObl");

            dataMatriculas.ForEach(x => dataTable.Rows.Add(
                x.C_CodRC,
                x.C_CodAlu,
                x.I_Anio,
                x.C_Periodo,
                x.C_EstMat,
                x.C_Ciclo,
                x.B_Ingresante,
                x.I_CredDesaprob,
                x.B_ActObl
            ));

            return dataTable;
        }

        public static List<DataMatriculaObs> DataMatriculaResult_To_DataMatriculaObs(List<DataMatriculaResult> dataMatriculaResult)
        {
            return dataMatriculaResult.Select(d  => new DataMatriculaObs() {
                C_CodRC = d.C_CodRC,
                C_CodAlu = d.C_CodAlu,
                I_Anio = d.I_Anio,
                C_Periodo = d.C_Periodo,
                C_EstMat = d.C_EstMat,
                C_Ciclo = d.C_Ciclo,
                B_Ingresante = d.B_Ingresante,
                I_CredDesaprob = d.I_CredDesaprob,
                B_Success = d.B_Success,
                T_Message = d.T_Message
            }).ToList();
        }

        public static ObligacionDetalleDTO VW_DetalleObligaciones_To_ObligacionDetalleDTO(VW_DetalleObligaciones detalleObligaciones)
        {
            var obligacionDetalleDTO = new ObligacionDetalleDTO()
            {
                C_CodAlu = detalleObligaciones.C_CodAlu,
                C_CodRc = detalleObligaciones.C_CodRc,
                I_Anio = detalleObligaciones.I_Anio,
                I_Periodo = detalleObligaciones.I_Periodo,
                T_Periodo = detalleObligaciones.T_Periodo,
                T_ConceptoDesc = detalleObligaciones.T_ConceptoDesc,
                T_CatPagoDesc = detalleObligaciones.T_CatPagoDesc,
                I_Monto = detalleObligaciones.I_Monto,
                B_Pagado = detalleObligaciones.B_Pagado,
                D_FecVencto = detalleObligaciones.D_FecVencto,
                I_Prioridad = detalleObligaciones.I_Prioridad
            };

            return obligacionDetalleDTO;
        }

        public static CuotaPagoDTO VW_CuotaPago_To_CuotaPagoDTO(VW_CuotasPago cuotaPago)
        {
            var cuotaPagoDTO = new CuotaPagoDTO()
            {
                I_ProcesoID = cuotaPago.I_ProcesoID,
                I_Anio = cuotaPago.I_Anio,
                I_Periodo = cuotaPago.I_Periodo,
                C_CodAlu = cuotaPago.C_CodAlu,
                C_CodRc = cuotaPago.C_CodRc,
                T_Periodo = cuotaPago.T_Periodo,
                T_CatPagoDesc = cuotaPago.T_CatPagoDesc,
                I_MontoTotal = cuotaPago.I_MontoTotal,
                D_FecVencto = cuotaPago.D_FecVencto
            };

            return cuotaPagoDTO;
        }
    }
}
