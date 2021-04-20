using Data.Tables;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ArchivoIntercambio : IArchivoIntercambio
    {
        public int? TipArchivoEntFinanID { get; set; }
        public int EntidadFinanID { get; set; }
        public string EntidadFinan { get; set; }
        public int TipoArchivoID { get; set; }
        public string TipoArchivo { get; set; }
        public bool Habilitado { get; set; }

        private readonly TI_TipoArchivo_EntidadFinanciera _tipoArchivo_Entidad;
        private readonly TC_EntidadFinanciera _entidadFinanciera;
        private readonly TC_SeccionArchivo _seccionArchivo;
        private readonly TC_ColumnaSeccion _columnaSeccion;

        public ArchivoIntercambio()
        {
            _tipoArchivo_Entidad = new TI_TipoArchivo_EntidadFinanciera();
            _entidadFinanciera = new TC_EntidadFinanciera();
            _seccionArchivo = new TC_SeccionArchivo();
            _columnaSeccion = new TC_ColumnaSeccion();
        }

        public Response ChangeState(int tipArchivoEntFinanID, bool currentState, int currentUserId)
        {
            _tipoArchivo_Entidad.I_TipArchivoEntFinanID = tipArchivoEntFinanID;
            _tipoArchivo_Entidad.D_FecMod = DateTime.Now;
            _tipoArchivo_Entidad.B_Habilitado = !currentState;

            return new Response(_tipoArchivo_Entidad.ChangeState(currentUserId));
        }

        public List<ArchivoIntercambio> Find()
        {
            var result = new List<ArchivoIntercambio>();

            foreach (var item in _tipoArchivo_Entidad.Find())
            {
                result.Add(new ArchivoIntercambio()
                {
                    TipArchivoEntFinanID = item.I_TipArchivoEntFinanID,
                    EntidadFinanID = item.I_EntidadFinanID,
                    EntidadFinan = item.T_EntidadDesc,
                    TipoArchivoID = item.I_TipoArchivoID,
                    TipoArchivo = item.T_TipoArchivDesc,
                    Habilitado = item.B_Habilitado
                });
            }

            return result;
        }

        public ArchivoIntercambio Find(int estructuraArchivoID)
        {
            var estructura = _tipoArchivo_Entidad.Find(estructuraArchivoID);

            return new ArchivoIntercambio()
            {
                TipArchivoEntFinanID = estructura.I_TipArchivoEntFinanID,
                EntidadFinanID = estructura.I_EntidadFinanID,
                EntidadFinan = estructura.T_EntidadDesc,
                TipoArchivoID = estructura.I_TipoArchivoID,
                TipoArchivo = estructura.T_TipoArchivDesc,
                Habilitado = estructura.B_Habilitado
            };

        }

        public Response Save(ArchivoIntercambio archivoIntercambio, int currentUserId, SaveOption saveOption)
        {
            _tipoArchivo_Entidad.I_TipArchivoEntFinanID = archivoIntercambio.TipArchivoEntFinanID.Value;
            _tipoArchivo_Entidad.I_TipoArchivoID = archivoIntercambio.TipoArchivoID;
            _tipoArchivo_Entidad.I_EntidadFinanID = archivoIntercambio.EntidadFinanID;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _tipoArchivo_Entidad.D_FecCre = DateTime.Now;
                    _tipoArchivo_Entidad.I_UsuarioCre = currentUserId;
                    return new Response(_tipoArchivo_Entidad.Insert());

                case SaveOption.Update:
                    _tipoArchivo_Entidad.D_FecMod = DateTime.Now;
                    _tipoArchivo_Entidad.I_UsuarioMod = currentUserId;
                    return new Response(_tipoArchivo_Entidad.Update());
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }

        public List<SeccionArchivo> FindSeccionesArchivos()
        {
            List<SeccionArchivo> result = new List<SeccionArchivo>();

            foreach (var item in _seccionArchivo.Find())
            {
                result.Add(new SeccionArchivo()
                {
                    SecArchivoID = item.I_SecArchivoID,
                    SecArchivoDesc = item.T_SecArchivoDesc,
                    FilaInicio = item.I_FilaInicio,
                    FilaFin = item.I_FilaFin,
                    Habilitado = item.B_Habilitado,
                    TipArchivoEntFinanID = item.I_TipArchivoEntFinanID,
                    TipoArchivDesc = item.T_TipoArchivDesc,
                    ArchivoEntrada = item.B_ArchivoEntrada,
                    EntidadDesc = item.T_EntidadDesc,
                    EntidadFinanID = item.I_EntidadFinanID,
                    TipoArchivoID = item.I_TipoArchivoID
                });
            }

            return result;
        }

        public List<ColumnaSeccion> FindColumnasSeccion()
        {
            List<ColumnaSeccion> result = new List<ColumnaSeccion>();

            foreach (var item in _columnaSeccion.Find())
            {
                result.Add(new ColumnaSeccion()
                {
                    SecArchivoID = item.I_SecArchivoID,
                    SecArchivoDesc = item.T_SecArchivoDesc,
                    ColumnaInicio = item.I_ColumnaInicio,
                    ColumnaFin = item.I_ColumnaFin,
                    Habilitado = item.B_Habilitado,
                    TipArchivoEntFinanID = item.I_TipArchivoEntFinanID,
                    CampoPagoID = item.I_CampoPagoID,
                    ColSecID = item.I_ColSecID,
                    ColSecDesc = item.T_ColSecDesc,
                    CampoPagoDesc = item.T_CampoInfoDesc,
                    CampoPagoNom = item.T_CampoPagoNom,
                    TablaPagoNom = item.T_TablaPagoNom
                });
            }

            return result;
        }

        public List<SeccionArchivo> FindSeccionesArchivos(int TipoArchivoEntidadID)
        {
            List<SeccionArchivo> result = new List<SeccionArchivo>();

            foreach (var item in _seccionArchivo.Find(TipoArchivoEntidadID))
            {
                result.Add(new SeccionArchivo()
                {
                    SecArchivoID = item.I_SecArchivoID,
                    SecArchivoDesc = item.T_SecArchivoDesc,
                    FilaInicio = item.I_FilaInicio,
                    FilaFin = item.I_FilaFin,
                    Habilitado = item.B_Habilitado,
                    TipArchivoEntFinanID = item.I_TipArchivoEntFinanID,
                    TipoArchivDesc = item.T_TipoArchivDesc,
                    ArchivoEntrada = item.B_ArchivoEntrada,
                    EntidadDesc = item.T_EntidadDesc,
                    EntidadFinanID = item.I_EntidadFinanID,
                    TipoArchivoID = item.I_TipoArchivoID
                });
            }

            return result;
        }

        public List<ColumnaSeccion> FindColumnasSeccion(int SeccionArchivoId)
        {
            List<ColumnaSeccion> result = new List<ColumnaSeccion>();

            foreach (var item in _columnaSeccion.FindBySectionID(SeccionArchivoId))
            {
                result.Add(new ColumnaSeccion()
                {
                    SecArchivoID = item.I_SecArchivoID,
                    SecArchivoDesc = item.T_SecArchivoDesc,
                    ColumnaInicio = item.I_ColumnaInicio,
                    ColumnaFin = item.I_ColumnaFin,
                    Habilitado = item.B_Habilitado,
                    TipArchivoEntFinanID = item.I_TipArchivoEntFinanID,
                    CampoPagoID = item.I_CampoPagoID,
                    ColSecID = item.I_ColSecID,
                    ColSecDesc = item.T_ColSecDesc,
                    CampoPagoDesc = item.T_CampoInfoDesc,
                    CampoPagoNom = item.T_CampoPagoNom,
                    TablaPagoNom = item.T_TablaPagoNom
                });
            }

            return result;
        }


        public Response SeccionChangeState(int seccionArchivoId, bool currentState, int currentUserId)
        {
            _seccionArchivo.I_TipArchivoEntFinanID = seccionArchivoId;
            _seccionArchivo.D_FecMod = DateTime.Now;
            _seccionArchivo.B_Habilitado = !currentState;

            return new Response(_seccionArchivo.ChangeState(currentUserId));
        }

        public Response ColumnaChangeState(int columnaSeccionId, bool currentState, int currentUserId)
        {
            _seccionArchivo.I_TipArchivoEntFinanID = columnaSeccionId;
            _seccionArchivo.D_FecMod = DateTime.Now;
            _seccionArchivo.B_Habilitado = !currentState;

            return new Response(_columnaSeccion.ChangeState(currentUserId));
        }



        public Response EstructuraSeccionSave(SeccionArchivo seccionesArchivo, List<ColumnaSeccion> columnasSeccion, int currentUserId, SaveOption saveOption)
        {
            Response resultSeccion;
            String ColumnErrors = "";

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _tipoArchivo_Entidad.D_FecCre = DateTime.Now;
                    _tipoArchivo_Entidad.I_UsuarioCre = currentUserId;
                    resultSeccion = new Response(_tipoArchivo_Entidad.Insert());
                    break;
                case SaveOption.Update:
                    _tipoArchivo_Entidad.D_FecMod = DateTime.Now;
                    _tipoArchivo_Entidad.I_UsuarioMod = currentUserId;
                    resultSeccion = new Response(_tipoArchivo_Entidad.Update());
                    break;
                default:
                    return new Response()
                    {
                        Value = false,
                        Message = "Operación Inváiida."
                    }; 
            }

            if (resultSeccion.Value)
            {
                foreach (var columna in columnasSeccion)
                {
                    var resultColumnas = EstructuraColumnaSeccionSave(columna, currentUserId, columna.ColSecID == 0 ? SaveOption.Insert : SaveOption.Update);

                    if (!resultColumnas.Value)
                    {
                        ColumnErrors += "- " + resultColumnas.Message + "\n";
                    }
                }
            }

            return new Response { Value = resultSeccion.Value, Message = resultSeccion.Message, Action = ColumnErrors };
        }


        private Response EstructuraColumnaSeccionSave(ColumnaSeccion columnaSeccion, int currentUserId, SaveOption saveOption)
        {
            _columnaSeccion.I_SecArchivoID = columnaSeccion.SecArchivoID;
            _columnaSeccion.I_ColSecID = columnaSeccion.ColSecID;
            _columnaSeccion.T_ColSecDesc = columnaSeccion.ColSecDesc;
            _columnaSeccion.I_ColumnaInicio = columnaSeccion.ColumnaInicio;
            _columnaSeccion.I_ColumnaFin = columnaSeccion.ColumnaFin;
            _columnaSeccion.I_CampoPagoID = columnaSeccion.CampoPagoID;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _columnaSeccion.D_FecCre = DateTime.Now;
                    _columnaSeccion.I_UsuarioCre = currentUserId;
                    return new Response(_columnaSeccion.Insert());

                case SaveOption.Update:
                    _columnaSeccion.D_FecMod = DateTime.Now;
                    _columnaSeccion.I_UsuarioMod = currentUserId;
                    return new Response(_columnaSeccion.Update());
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }
    }
}
