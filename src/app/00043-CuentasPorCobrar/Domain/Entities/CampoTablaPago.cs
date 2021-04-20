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
    public class CampoTablaPago : ICampoTablaPago
    {
        public int? CampoId { get; set; }
        public string DescCampo { get; set; }
        public string NombreTabla { get; set; }
        public string NombreCampoTabla { get; set; }
        public int TipoArchivo { get; set; }
        public bool? Habilitado { get; set; }

        private readonly TS_CampoTablaPago _CampoTablaPago;

        public CampoTablaPago()
        {
            _CampoTablaPago = new TS_CampoTablaPago();
        }

        public Response ChangeState(int campoId, bool currentState, int currentUserId)
        {
            _CampoTablaPago.I_CampoPagoID = campoId;
            _CampoTablaPago.D_FecMod = DateTime.Now;
            _CampoTablaPago.B_Habilitado = !currentState;

            return new Response(_CampoTablaPago.ChangeState(currentUserId));
        }

        public List<CampoTablaPago> Find()
        {
            List<CampoTablaPago> result = new List<CampoTablaPago>();

            foreach (var item in _CampoTablaPago.Find())
            {
                result.Add(new CampoTablaPago()
                {
                    CampoId = item.I_CampoPagoID,
                    DescCampo = item.T_CampoInfoDesc,
                    NombreCampoTabla = item.T_CampoPagoNom,
                    NombreTabla = item.T_TablaPagoNom,
                    TipoArchivo = item.I_TipoArchivoID,
                    Habilitado = item.B_Habilitado,
                });
            }

            return result;
        }

        public CampoTablaPago Find(int campoId)
        {
            var campo = _CampoTablaPago.Find(campoId);

            CampoTablaPago result = new CampoTablaPago()
            {
                CampoId = campo.I_CampoPagoID,
                DescCampo = campo.T_CampoInfoDesc,
                NombreCampoTabla = campo.T_CampoPagoNom,
                NombreTabla = campo.T_TablaPagoNom,
                TipoArchivo = campo.I_TipoArchivoID,
                Habilitado = campo.B_Habilitado,
            };

            return result;
        }

        public Response Save(CampoTablaPago campoTablaPago, int currentUserId, SaveOption saveOption)
        {
            _CampoTablaPago.I_TipoArchivoID = campoTablaPago.TipoArchivo;
            _CampoTablaPago.T_CampoInfoDesc = campoTablaPago.DescCampo;
            _CampoTablaPago.T_TablaPagoNom = campoTablaPago.NombreTabla;
            _CampoTablaPago.T_CampoPagoNom = campoTablaPago.NombreCampoTabla;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _CampoTablaPago.I_UsuarioCre = currentUserId;
                    _CampoTablaPago.D_FecCre = DateTime.Now;
                    return new Response(_CampoTablaPago.Insert());

                case SaveOption.Update:
                    _CampoTablaPago.I_CampoPagoID = campoTablaPago.CampoId.Value;
                    _CampoTablaPago.I_UsuarioMod = currentUserId;
                    _CampoTablaPago.D_FecMod = DateTime.Now;
                    return new Response(_CampoTablaPago.Update());
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }

        public List<string> GetBDTables()
        {
            return _CampoTablaPago.GetTables().OrderBy(x => x).ToList();
        }

        public List<string> GetBDColumns(string tableName)
        {
            return _CampoTablaPago.GetColumns(tableName);
        }
    }
}
