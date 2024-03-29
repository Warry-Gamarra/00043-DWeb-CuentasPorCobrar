﻿using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TI_TasaUnfv
    {
        public int I_TasaUnfvID { get; set; }
        public int I_ConceptoID { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public bool? B_Fraccionable { get; set; }
        public bool? B_ConceptoGeneral { get; set; }
        public bool? B_AgrupaConcepto { get; set; }
        public int? I_AlumnosDestino { get; set; }
        public int? I_GradoDestino { get; set; }
        public int? I_TipoObligacion { get; set; }
        public string T_Clasificador { get; set; }
        public string C_CodTasa { get; set; }
        public bool? B_Calculado { get; set; }
        public int? I_Calculado { get; set; }
        public bool? B_AnioPeriodo { get; set; }
        public int? I_Anio { get; set; }
        public int? I_Periodo { get; set; }
        public bool? B_Especialidad { get; set; }
        public char? C_CodRc { get; set; }
        public bool? B_Dependencia { get; set; }
        public int? C_DepCod { get; set; }
        public bool? B_GrupoCodRc { get; set; }
        public int? I_GrupoCodRc { get; set; }
        public bool? B_ModalidadIngreso { get; set; }
        public int? I_ModalidadIngresoID { get; set; }
        public bool? B_ConceptoAgrupa { get; set; }
        public int? I_ConceptoAgrupaID { get; set; }
        public bool? B_ConceptoAfecta { get; set; }
        public int? I_ConceptoAfectaID { get; set; }
        public int? N_NroPagos { get; set; }
        public bool? B_Porcentaje { get; set; }
        public string C_Moneda { get; set; }
        public decimal? M_Monto { get; set; }
        public decimal? M_MontoMinimo { get; set; }
        public string T_DescripcionLarga { get; set; }
        public string T_Documento { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Migrado { get; set; }

        public static TI_TasaUnfv FindByID(int I_TasaUnfvID)
        {
            TI_TasaUnfv result;

            try
            {
                string s_command = @"SELECT c.* FROM TI_TasaUnfv c where c.I_TasaUnfvID = @I_TasaUnfvID AND c.B_Eliminado = 0";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_TasaUnfv>(s_command, new { I_TasaUnfvID = I_TasaUnfvID }, commandType: CommandType.Text).FirstOrDefault();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public ResponseData ChangeState(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_TasaUnfvID", dbType: DbType.Int32, value: this.I_TasaUnfvID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoTasaUnfv", parameters, commandType: CommandType.StoredProcedure);

                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                result.Value = false;
                result.Message = ex.Message;
            }
            return result;
        }
    }
}

