using Data.Procedures;
using Data;
using Data.Tables;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class TipoComprobanteService : ITipoComprobanteService
    {
        public IEnumerable<TipoComprobanteDTO> ListarTiposComprobante(bool soloHabilitados)
        {
            var lista = TC_TipoComprobante.GetAll();

            if (soloHabilitados )
            {
                lista = lista.Where(x => x.B_Habilitado);
            }

            var result = lista.Select(x => Mapper.TC_TipoComprobante_To_TipoComprobanteDTO(x));

            return result;
        }

        public Response GrabarTipoComprobante(TipoComprobanteEntity entity, SaveOption saveOption, int userID)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:

                    if (!ListarTiposComprobante(false).Any(x => x.tipoComprobanteCod == entity.tipoComprobanteCod))
                    {
                        var grabar = new USP_I_GrabarTipoComprobante()
                        {
                            C_TipoComprobanteCod = entity.tipoComprobanteCod,
                            T_TipoComprobanteDesc = entity.tipoComprobanteDesc,
                            T_Inicial = entity.inicial,
                            UserID = userID
                        };

                        result = grabar.Execute();
                    }
                    else
                    {
                        result = new ResponseData()
                        {
                            Message = String.Format("El código \"{0}\" ya se encuentra registrado en el sistema.", entity.tipoComprobanteCod)
                        };
                    }

                    break;

                case SaveOption.Update:

                    if (entity.tipoComprobanteID.HasValue)
                    {
                        if (!ListarTiposComprobante(false).Any(x => x.tipoComprobanteID != entity.tipoComprobanteID && x.tipoComprobanteCod == entity.tipoComprobanteCod))
                        {
                            var actualizar = new USP_U_ActualizarTipoComprobante()
                            {
                                I_TipoComprobanteID = entity.tipoComprobanteID.Value,
                                C_TipoComprobanteCod = entity.tipoComprobanteCod,
                                T_TipoComprobanteDesc = entity.tipoComprobanteDesc,
                                T_Inicial = entity.inicial,
                                UserID = userID
                            };

                            result = actualizar.Execute();
                        }
                        else
                        {
                            result = new ResponseData()
                            {
                                Message = String.Format("El código \"{0}\" ya se encuentra registrado en el sistema.", entity.tipoComprobanteCod)
                            };
                        }
                    }
                    else
                    {
                        result = new ResponseData()
                        {
                            Message = "Ocurrió un error al obtener los datos. Por favor recargue la página e intente la actualización nuevamente."
                        };
                    }

                    break;

                default:
                    result = new ResponseData()
                    {
                        Value = false,
                        Message = "Acción no válida."
                    };

                    break;
            }

            return new Response(result);
        }

        public Response ActualizarEstadoTipoComprobante(int tipoComprobanteID, bool estaHabilitado, int userID)
        {
            ResponseData result;

            var sp = new USP_U_ActualizarEstadoTipoComprobante()
            {
                I_TipoComprobanteID = tipoComprobanteID,
                B_Habilitado = !estaHabilitado,
                UserID = userID
            };

            result = sp.Execute();

            return new Response(result);
        }

        public Response EliminarTipoComprobante(int tipoComprobanteID)
        {
            ResponseData result;

            if (!TR_Comprobante.ExistByTipo(tipoComprobanteID))
            {
                var sp = new USP_D_EliminarTipoComprobante()
                {
                    I_TipoComprobanteID = tipoComprobanteID
                };

                result = sp.Execute();
            }
            else
            {
                result = new ResponseData()
                {
                    Message = "No se puede eliminar el registro seleccionado. Ya se generaron comprobantes con este tipo."
                };
            }
            
            return new Response(result);
        }
    }
}
